Chance = require "chance"
chance = new Chance()

_ = require "underscore"
_.str = require "underscore.string"

Datastore = require "./DatabaseWrapper"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
Battle = require "../event/Battle"

Party = require "../event/Party"

class EventHandler

  constructor: (@game) ->
    @playerEventsDb = new Datastore "playerEvents", (db) -> db.ensureIndex {createdAt: 1}, {expiresAfterSeconds: 7200}, ->

  doEventForPlayer: (playerName, eventType = Constants.pickRandomNormalEventType(), callback) ->
    player = @game.playerManager.getPlayerByName playerName
    if not player
      console.error "Attempting to do event #{eventType} for #{playerName}, but player was not there."
      return callback?()

    @doEvent eventType, player, callback

  doEvent: (eventType, player, callback = ->) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      console.error e if e
      return if not event or not player
      player.emit "event", event
      switch eventType
        when 'yesno'
          @doYesNo event, player, callback
        when 'blessXp', 'forsakeXp'
          @doXp event, player, callback
        when 'blessGold', 'forsakeGold'
          @doGold event, player, callback
        when 'blessItem', 'forsakeItem'
          @doItem event, player, callback
        when 'findItem'
          @doFindItem event, player, callback
        when 'party'
          @doParty event, player, callback
        when 'enchant'
          @doEnchant event, player, callback
        when 'flipStat'
          @doFlipStat event, player, callback
        when 'battle'
          @doMonsterBattle event, player, callback

      player.recalculateStats()

  bossBattle: (player, bossName) ->
    return if @game.inBattle
    doBossBattle = =>
      boss = @game.bossFactory.createBoss bossName, player
      return if not boss

      message = ">>> BOSS BATTLE: %player prepares for an epic battle!"
      message = MessageCreator.doStringReplace message, player
      @game.broadcast MessageCreator.genericMessage message

      bossParty = new Party @game, boss

      new Battle @game, [player.party, bossParty]

    if player.party
      doBossBattle()
    else
      @doEventForPlayer player.name, 'party', doBossBattle

  broadcastEvent: (message, player, extra) ->
    message = MessageCreator.doStringReplace message, player, extra
    @game.broadcast MessageCreator.genericMessage message

    @addEventToDb message, player

  addEventToDb: (message, player) ->
    @playerEventsDb.insert
      createdAt: new Date()
      player: player.name
      message: MessageCreator._replaceMessageColors message
    , ->

  doYesNo: (event, player, callback) ->
    #player.emit "yesno"
    if chance.bool {likelihood: player.calculateYesPercent()}
      (@broadcastEvent event.y, player) if event.y
      callback true
    else
      (@broadcastEvent event.n, player) if event.n
      callback false

  doXp: (event, player, callback) ->
    if not event.remark
      console.error "XP EVENT FAILURE", event
      return callback false

    boost = 0
    percent = 0

    if (chance.bool {likelihood: player.calculateYesPercent()})
      percent = Constants.eventEffects[event.type].fail
      boost = Math.floor player.xp.maximum * (percent/100)
    else
      min = Constants.eventEffects[event.type].minPercent
      max = Constants.eventEffects[event.type].maxPercent
      flux = Constants.eventEffects[event.type].flux
      step = player.level.maximum / (max - min)
      steps = Math.floor ((player.level.maximum - player.level.getValue()) / step)

      fluxed = chance.floating {min: -flux, max: flux, fixed: 3}

      percent = min + steps + fluxed

      boost = Math.floor player.xp.maximum * (percent/100)

    boost = player.calcXpGain boost

    extra =
      xp: Math.abs boost
      realXp: boost
      percentXp: +(percent).toFixed 3

    message = "#{event.remark} [%realXpxp, ~%percentXp%]"

    @broadcastEvent message, player, extra

    player.gainXp boost

    player.emit "event.#{event.type}", player, extra

    callback true

  doGold: (event, player, callback) ->
    if not event.remark
      console.error "GOLD EVENT FAILURE", event
      return callback false

    goldTiers = Constants.eventEffects[event.type].amount
    curGold = player.gold.getValue()

    boost = 0
    for i in [0...goldTiers.length]
      if curGold < Math.abs goldTiers[i]
        highVal = if not goldTiers[i-1] then 100 else goldTiers[i-1]
        lowVal = if not goldTiers[i] then 1 else goldTiers[i]

        min = Math.min highVal, lowVal
        max = Math.max highVal, lowVal
        boost = chance.integer {min: min, max: max}
        break

    if not boost
      val = _.last goldTiers
      min = Math.min val, 0
      max = Math.max val, 1
      boost = chance.integer min: min, max: max

    if _.isNaN boost
      console.error "BOOST PRE-CALC IS NaN"
      boost = 1

    boost = player.calcGoldGain boost

    if _.isNaN boost
      console.error "BOOST POST-CALC IS NaN"
      boost = 1

    extra =
      gold: Math.abs boost
      realGold: boost

    player.gainGold boost

    player.emit "event.#{event.type}", player, extra

    message = event.remark + " [%realGold gold]"

    @broadcastEvent message, player, extra
    callback true

  doItem: (event, player, callback) ->
    item = (_.sample player.equipment)
    stat = @pickBlessStat item
    return callback false if not stat

    val = item[stat] ? 0

    boost = 0

    if (chance.bool {likelihood: player.calc.eventFumble()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor Math.abs(val) / Constants.eventEffects[event.type].percent

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    start = val
    end = val+boost

    return callback false if start is end

    item[stat] = end

    string = MessageCreator.doStringReplace event.remark, player, extra
    string += " [<event.blessItem.stat>#{stat}</event.blessItem.stat> <event.blessItem.value>#{start} -> #{end}</event.blessItem.value>]"

    player.emit "event.#{event.type}", player, item, boost

    @broadcastEvent string, player
    callback true

  doItemEquip: (player, item, messageString) ->
    myItem = _.findWhere player.equipment, {type: item.type}
    score = player.calc.itemScore item
    myScore = player.calc.itemScore myItem
    realScore = item.score()
    myRealScore = myItem.score()

    player.equip item

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    realScoreDiff = realScore-myRealScore
    perceivedScoreDiff = score-myScore
    normalizedRealScore = if realScoreDiff > 0 then "+#{realScoreDiff}" else realScoreDiff
    normalizedPerceivedScore = if perceivedScoreDiff > 0 then "+#{perceivedScoreDiff}" else perceivedScoreDiff

    totalString = "#{messageString} [perceived: <event.finditem.perceived>#{myScore} -> #{score} (#{normalizedPerceivedScore})</event.finditem.perceived> | real: <event.finditem.real>#{myRealScore} -> #{realScore} (#{normalizedRealScore})</event.finditem.real>]"
    player.emit "event.findItem", player, item

    @broadcastEvent totalString, player, extra

  doFindItem: (event, player, callback) ->
    item = @game.equipmentGenerator.generateItem null, player.calc.luckBonus()
    return if not item
    myItem = _.findWhere player.equipment, {type: item.type}
    return callback false if not myItem
    score = player.calc.itemScore item
    myScore = player.calc.itemScore myItem
    realScore = item.score()

    if score > myScore and realScore < player.calc.itemFindRange() and (chance.bool likelihood: player.calc.itemReplaceChancePercent())
      @doItemEquip player, item, event.remark

    else
      multiplier = player.calc.itemSellMultiplier item
      value = Math.floor item.score() * multiplier
      player.gainGold value
      player.emit "event.sellItem", player, item, value

    callback true

  doParty: (event, player, callback) ->
    return callback false if player.party or @game.inBattle
    newParty = @game.createParty player
    return callback false if not newParty?.name

    newPartyPlayers = _.without newParty.players, player

    extra =
      partyMembers: _.str.toSentence _.pluck newPartyPlayers, 'name'
      partyName: newParty.name

    @broadcastEvent event.remark, player, extra

    callback true

  doMonsterBattle: (event, player, callback) ->
    event.player = player

    new Party @game, player if not player.party
    party = player.party
    return if not player.party

    monsterParty = @game.monsterGenerator.generateMonsterParty party.score()
    return if monsterParty.players.length is 0

    @game.startBattle [monsterParty, player.party], event
    player.emit "event.monsterbattle", player

    callback true

  doEnchant: (event, player, callback) ->
    item = _.sample _.reject player.equipment, (item) -> item.enchantLevel >= Constants.defaults.game.maxEnchantLevel

    return callback false if not item
    stat = @pickStatNotPresentOnItem item

    boost = 10

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    item[stat] += boost

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    string = "#{event.remark} [<event.enchant.stat>#{stat} = #{boost}</event.enchant.stat> | <event.enchant.boost>+#{item.enchantLevel} -> +#{++item.enchantLevel}</event.enchant.boost>]"

    player.emit "event.enchant", player, item, item.enchantLevel

    @broadcastEvent string, player, extra
    callback true

  doFlipStat: (event, player, callback) ->
    item = (_.sample player.equipment)
    stat = @pickStatPresentOnItem item

    return callback false if not stat or item[stat] is 0

    val = item[stat] ? 0

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    start = val
    end = -val

    item[stat] = end

    string = "#{event.remark} [<event.flip.stat>#{stat}</event.flip.stat> <event.flip.value>#{start} -> #{end}</event.flip.value>]"

    player.emit "event.#{event.type}", player, item, stat

    @broadcastEvent string, player, extra
    callback true

  ignoreKeys: ['_calcScore', 'enchantLevel']
  specialStats: ['offense', 'defense', 'prone', 'power', 'silver', 'crit', 'dance', 'deadeye', 'glowing', 'vorpal']
  t0: ['int', 'str', 'dex', 'con', 'wis', 'agi']
  t1: ['intPercent', 'strPercent', 'conPercent', 'wisPercent', 'agiPercent']
  t2: ['gold', 'xp', 'hp', 'mp']
  t3: ['goldPercent', 'xpPercent', 'hpPercent', 'mpPercent', 'luck']
  t4: ['luckPercent']

  allValidStats: -> @t0.concat @t1.concat @t2.concat @t3.concat @t4

  pickStatPresentOnItem: (item, base = @allValidStats()) ->
    nonZeroStats = _.reject (_.keys item), (stat) -> item[stat] is 0 or _.isNaN item[stat]
    statsInBoth = _.intersection base, nonZeroStats
    _.sample statsInBoth

  pickStatNotPresentOnItem: (item, base = @allValidStats()) ->
    zeroStats = _.filter (_.keys item), (stat) -> item[stat] is 0
    statsMissing = _.intersection base, zeroStats
    _.sample statsMissing

  pickBlessStat: (item) ->
    chances = [1, 5, 10, 20, 100]
    keys = [@t4, @t3, @t2, @t1, @t0]
    validKeysToChoose = _.compact _.map keys, (keyList) =>
      @pickStatPresentOnItem item, keyList

    return '' if validKeysToChoose.length is 0

    chances = chances[-validKeysToChoose.length..]

    retStat = ''
    for i in [0..validKeysToChoose.length]
      if chance.bool {likelihood: chances[i]}
        retStat = validKeysToChoose[i]
        break

    retStat

module.exports = exports = EventHandler
