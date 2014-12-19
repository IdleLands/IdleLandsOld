chance = new (require "chance")()

_ = require "lodash"
_.str = require "underscore.string"

Datastore = require "./DatabaseWrapper"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
Battle = require "../event/Battle"

Party = require "../event/Party"

requireDir = require "require-dir"
allEvents = requireDir "../event/singles"

class EventHandler

  constructor: (@game) ->
    @playerEventsDb = new Datastore "playerEvents", (db) -> db.ensureIndex {createdAt: 1}, {expiresAfterSeconds: 7200}, ->

  doEventForPlayer: (playerName, eventType = null) ->
    player = @game.playerManager.getPlayerByName playerName
    eventType = Constants.pickRandomNormalEventType(player) if not eventType
    if not player
      console.error "Attempting to do event #{eventType} for #{playerName}, but player was not there."
      return callback?()

    @doEvent eventType, player

  doEvent: (eventType, player) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      console.error "CANT GET EVENT",e,e.stack if e
      return if not event or not player

      callback = (res) -> if res then player.emit "event", event

      switch eventType
        when 'yesno'
          @doYesNo event, player, callback

        when 'providence'
          (new allEvents.ProvidenceEvent @game, event, player).go()

        when 'levelDown'
          (new allEvents.LevelDownEvent @game, event, player).go()

        when 'blessXp', 'forsakeXp'
          (new allEvents.XpEvent @game, event, player).go()

        when 'blessXpParty', 'forsakeXpParty'
          (new allEvents.XpPartyEvent @game, event, player).go()

        when 'blessGold', 'forsakeGold'
          (new allEvents.GoldEvent @game, event, player).go()

        when 'blessGoldParty', 'forsakeGoldParty'
          (new allEvents.GoldPartyEvent @game, event, player).go()

        when 'blessItem', 'forsakeItem'
          (new allEvents.ItemModEvent @game, event, player).go()

        when 'findItem'
          (new allEvents.FindItemEvent @game, event, player).go()

        when 'merchant'
          (new allEvents.MerchantEvent @game, event, player).go()

        when 'party'
          (new allEvents.PartyEvent @game, event, player).go()

        when 'enchant', 'tinker'
          (new allEvents.EnchantEvent @game, event, player).go()

        when 'flipStat'
          (new allEvents.FlipStatEvent @game, event, player).go()

        when 'battle'
          (new allEvents.MonsterBattleEvent @game, event, player).go()

      player.recalculateStats()

  bossBattle: (player, bossName) ->
    console.error "DOING BOSS #{bossName}"
    return if @game.inBattle

    boss = @createBoss bossName
    return if not boss

    bossParty = new Party @game, boss

    @bossBattleParty player, bossParty

  bossPartyBattle: (player, bossPartyName) ->
    console.error "DOING BOSS #{bossPartyName}"
    monsters = @createBosses @game.bossFactory.createBossPartyNames bossPartyName
    bossParty = new Party @game, monsters

    @bossBattleParty player, bossParty

  createBoss: (bossName) ->
    @game.bossFactory.createBoss bossName

  createBosses: (bossNames) ->
    _.map bossNames, @createBoss

  bossBattleParty: (player, bossParty) ->

    if not player.party
      if player.calc.totalItemScore() < bossParty.score()
        @doEventForPlayer player.name, 'party'
      else
        new Party @game, [player]

    message = ">>> BOSS BATTLE: %player prepares for an epic battle!"
    message = MessageCreator.doStringReplace message, player
    @game.broadcast MessageCreator.genericMessage message

    new Battle @game, [player.party, bossParty]

  # sendMessage = no implies that you're forwarding the original message to multiple people
  broadcastEvent: (options) ->
    {message, player, extra, sendMessage, type, link} = options
    sendMessage = yes if _.isUndefined sendMessage
    extra = {} if not extra

    return if player.isMonster

    if sendMessage
      message = MessageCreator.doStringReplace message, player, extra
      @game.broadcast MessageCreator.genericMessage message

    stripped = MessageCreator._replaceMessageColors message

    if link
      player.pushbulletSend extra.linkTitle, link
    else player.pushbulletSend stripped
    @addEventToDb stripped, player, type, extra

    message

  addEventToDb: (message, player, type, extra = {}) ->

    event =
      createdAt: new Date()
      player: player.name
      message: message
      type: type
      extra: extra

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

  tryToEquipItem: (event, player, item) ->

    rangeBoost = event.rangeBoost ?= 1

    if (player.canEquip item, rangeBoost) and (chance.bool likelihood: player.calc.itemReplaceChancePercent())
      @doItemEquip player, item, event.remark
      return true

    else
      multiplier = player.calc.itemSellMultiplier item
      value = Math.floor item.score() * multiplier
      player.gainGold value
      player.emit "player.sellItem", player, item, value

module.exports = exports = EventHandler
