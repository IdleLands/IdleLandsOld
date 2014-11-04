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

  doEvent: (eventType, player, callback = null) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      console.error e if e
      return if not event or not player

      callback = (res) -> if res then player.emit "event", event

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

  # sendMessage = no implies that you're forwarding the original message to multiple people
  broadcastEvent: (options) ->
    {message, player, extra, sendMessage, type} = options
    sendMessage = yes if _.isUndefined sendMessage
    extra = {} if not extra

    if sendMessage
      message = MessageCreator.doStringReplace message, player, extra
      @game.broadcast MessageCreator.genericMessage message

    stripped = MessageCreator._replaceMessageColors message

    player.pushbulletSend stripped
    @addEventToDb stripped, player, type

    message

  addEventToDb: (message, player, type) ->

    event =
      createdAt: new Date()
      player: player.name
      message: message
      type: type

    player.recentEvents = [] if not player.recentEvents
    player.recentEvents.push event
    player.recentEvents.shift() if player.recentEvents.length > Constants.defaults.player.maxRecentEvents

    @playerEventsDb.insert event, ->

  doYesNo: (event, player, callback) ->
    #player.emit "yesno"
    if chance.bool {likelihood: player.calculateYesPercent()}
      (@broadcastEvent message: event.y, player: player, type: 'miscellaneous') if event.y
      callback true
    else
      (@broadcastEvent message: event.n, player: player, type: 'miscellaneous') if event.n
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

    @broadcastEvent {message: message, player: player, extra: extra, type: 'exp'}

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

    @broadcastEvent {message: message, player: player, extra: extra, type: 'gold'}
    callback true

  doItem: (event, player, callback) ->
    item = @pickValidItem player
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

    @broadcastEvent {message: string, player: player, type: 'item-mod'}
    player.emit "event.#{event.type}", player, item, boost

    callback true

  doItemEquip: (player, item, messageString) ->
    myItem = _.findWhere player.equipment, {type: item.type}
    score = (player.calc.itemScore item).toFixed 1
    myScore = (player.calc.itemScore myItem).toFixed 1
    realScore = item.score().toFixed 1
    myRealScore = myItem.score().toFixed 1

    player.equip item

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    realScoreDiff = (realScore-myRealScore).toFixed 1
    perceivedScoreDiff = (score-myScore).toFixed 1
    normalizedRealScore = if realScoreDiff > 0 then "+#{realScoreDiff}" else realScoreDiff
    normalizedPerceivedScore = if perceivedScoreDiff > 0 then "+#{perceivedScoreDiff}" else perceivedScoreDiff

    totalString = "#{messageString} [perceived: <event.finditem.perceived>#{myScore} -> #{score} (#{normalizedPerceivedScore})</event.finditem.perceived> | real: <event.finditem.real>#{myRealScore} -> #{realScore} (#{normalizedRealScore})</event.finditem.real>]"
    
    @broadcastEvent {message: totalString, player: player, extra: extra, type: 'item-find'}
    player.emit "event.findItem", player, item

  doItemEvent: (event, player, item, callback) ->
    myItem = _.findWhere player.equipment, {type: item.type}
    return callback false if not myItem
    score = player.calc.itemScore item
    myScore = player.calc.itemScore myItem
    realScore = item.score()

    rangeBoost = event.rangeBoost ?= 1

    if score > myScore and realScore < player.calc.itemFindRange()*rangeBoost and (chance.bool likelihood: player.calc.itemReplaceChancePercent())
      @doItemEquip player, item, event.remark
      callback true

    else
      multiplier = player.calc.itemSellMultiplier item
      value = Math.floor item.score() * multiplier
      player.gainGold value
      player.emit "player.sellItem", player, item, value
      callback false

  doFindItem: (event, player, callback) ->
    item = @game.equipmentGenerator.generateItem null, player.calc.luckBonus()
    return if not item

    @doItemEvent event, player, item, callback

  doParty: (event, player, callback) ->
    return callback false if player.party or @game.inBattle
    newParty = @game.createParty player
    return callback false if not newParty?.name

    newPartyPlayers = _.without newParty.players, player

    extra =
      partyMembers: _.str.toSentence _.pluck newPartyPlayers, 'name'
      partyName: newParty.name

    message = @broadcastEvent {message: event.remark, player: player, extra: extra, type: 'party'}
    _.each newPartyPlayers, (newMember) => @broadcastEvent {message: message, player: newMember, extra: extra, sendMessage: no, type: 'party'}

    callback true

  doMonsterBattle: (event, player, callback) ->
    event.player = player

    new Party @game, player if not player.party
    party = player.party
    return if not player.party

    monsterParty = @game.monsterGenerator.generateMonsterParty party.score()
    return if not monsterParty or monsterParty.players.length is 0

    @game.startBattle [monsterParty, player.party], event
    player.emit "event.monsterbattle", player

    callback true

  doEnchant: (event, player, callback) ->
    item = _.sample _.reject player.equipment, (item) -> item.enchantLevel >= Constants.defaults.game.maxEnchantLevel

    return callback false if (not item) or (item.name is "empty")
    stat = @pickStatNotPresentOnItem item

    boost = 10

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    item[stat] += boost

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    string = "#{event.remark} [<event.enchant.stat>#{stat} = #{boost}</event.enchant.stat> | <event.enchant.boost>+#{item.enchantLevel} -> +#{++item.enchantLevel}</event.enchant.boost>]"

    @broadcastEvent {message: string, player: player, extra: extra, type: 'item-enchant'}
    player.emit "event.enchant", player, item, item.enchantLevel
    
    callback true

  doFlipStat: (event, player, callback) ->
    item = @pickValidItem player
    stat = @pickStatPresentOnItem item

    return callback false if not stat or item[stat] is 0

    val = item[stat] ? 0

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    start = val
    end = -val

    item[stat] = end

    string = "#{event.remark} [<event.flip.stat>#{stat}</event.flip.stat> <event.flip.value>#{start} -> #{end}</event.flip.value>]"

    @broadcastEvent {message: string, player: player, extra: extra, type: 'item-switcheroo'}
    player.emit "event.flipStat", player, item, stat, val

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

  pickValidItem: (player) ->
    items = player.equipment
    forsaken = _.findWhere items, {forsaken: 1}
    return forsaken if forsaken
    nonSacred = _.reject items, (item) -> item.sacred
    _.sample nonSacred

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
