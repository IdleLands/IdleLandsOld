Chance = require "chance"
chance = new Chance()

_ = require "underscore"
_.str = require "underscore.string"

Datastore = require "./DatabaseWrapper"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

Party = require "../event/Party"

class EventHandler

  constructor: (@game) ->
    @playerEventsDb = new Datastore "playerEvents", (db) -> db.ensureIndex {createdAt: 1}, {expiresAfterSeconds: 7200}, ->

  doEventForPlayer: (playerName, callback, eventType = Constants.pickRandomNormalEventType()) ->
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

  broadcastEvent: (message, player, extra) ->
    message = MessageCreator.doStringReplace message, player, extra
    @game.broadcast MessageCreator.genericMessage message

    @addEventToDb message, player

  addEventToDb: (message, player) ->
    @playerEventsDb.insert
      createdAt: new Date()
      player: player.name
      message: message
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
    stat = @validItemStat item
    return callback false if not stat

    val = item[stat] ? 0

    boost = 0

    if (chance.bool {likelihood: player.calc.eventFumble()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor Math.abs(val) / Constants.eventEffects[event.type].percent

    extra =
      item: item.getName()

    start = val
    end = val+boost

    return callback false if start is end

    item[stat] = end

    string = MessageCreator.doStringReplace event.remark, player, extra
    string += " [#{stat} #{start} -> #{end}]"

    player.emit "event.#{event.type}", player, item, boost

    @broadcastEvent string, player
    callback true

  doFindItem: (event, player, callback) ->
    item = @game.equipmentGenerator.generateItem()
    myItem = _.findWhere player.equipment, {type: item.type}
    return callback false if not myItem
    score = player.calc.itemScore item
    myScore = player.calc.itemScore myItem
    realScore = item.score()
    myRealScore = myItem.score()

    if score >= myScore and realScore < player.itemFindRange() and (chance.bool likelihood: player.calc.itemReplaceChancePercent())
      player.equip item

      extra =
        item: item.getName()

      totalString = "#{event.remark} [perceived: #{myScore} -> #{score} | real: #{myRealScore} -> #{realScore} | +#{score-myScore}]"
      player.emit "event.findItem", player, item

      @broadcastEvent totalString, player, extra

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

    monsterParty = @game.monsterGenerator.generateMonsterParty party.score()

    console.log party.score(), monsterParty.score()

    @game.startBattle [monsterParty, player.party], event
    player.emit "event.monsterbattle", player

    callback true

  doEnchant: (event, player, callback) ->
    item = _.sample _.reject player.equipment, (item) -> item.enchantLevel >= Constants.defaults.game.maxEnchantLevel

    return callback false if not item
    stat = @validItemStat item

    boost = 10

    extra =
      item: item.getName()

    item[stat] += boost

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    string = "#{event.remark} [#{stat} = #{boost} | +#{item.enchantLevel} -> +#{++item.enchantLevel}]"

    player.emit "event.enchant", player, item, item.enchantLevel

    @broadcastEvent string, player, extra
    callback true

  doFlipStat: (event, player, callback) ->
    item = (_.sample player.equipment)
    stat = @validItemStat item

    return callback false if not stat or item[stat] is 0

    val = item[stat] ? 0

    extra =
      item: item.getName()

    start = val
    end = -val

    item[stat] = end

    string = "#{event.remark} [#{stat} #{start} -> #{end}]"

    player.emit "event.#{event.type}", player, item, stat

    @broadcastEvent string, player, extra
    callback true

  specialStats: ['offense', 'defense', 'prone', 'power', 'silver', 'crit', 'dance', 'deadeye', 'glowing', 'vorpal']

  validItemStat: (item) ->
    _.sample (_.reject (_.keys item), (key) -> key is 'enchantLevel' or item[key] is 0 or not _.isNumber item[key] or key of @specialStats)

module.exports = exports = EventHandler
