chance = new (require "chance")()

_ = require "lodash"
_.str = require "underscore.string"

Datastore = require "./../database/DatabaseWrapper"
MessageCreator = require "./MessageCreator"
Constants = require "./../utilities/Constants"
Battle = require "../../event/Battle"
Q = require "q"

Party = require "../../event/Party"

requireDir = require "require-dir"
allEvents = requireDir "../../event/singles"

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
    defer = Q.defer()
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      @game.errorHandler.captureException e if e
      return if not event or not player

      callback = (res) -> if res then player.emit "event", event

      try
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

          when 'advertisement'
            (new allEvents.AdvertisementEvent @game, event, player).go()

      catch e
        @game.errorHandler.captureException e, extra: name: player.name, gear: player.equipment, inv: player.overflow

      player.recalculateStats()
      defer.resolve()

    defer.promise

  bossBattle: (player, bossName) ->
    return if @game.inBattle

    boss = @createBoss bossName
    return if not boss

    bossParty = new Party @game, boss

    @bossBattleParty player, bossParty, bossName

  bossPartyBattle: (player, bossPartyName) ->
    return if @game.bossFactory.cantDoBossPartyBattle bossPartyName
    monsters = @createBosses (@game.bossFactory.createBossPartyNames bossPartyName), bossPartyName

    try
      bossParty = new Party @game, monsters
    catch e
      @game.errorHandler.captureException e, extra: partyName: bossPartyName

    @bossBattleParty player, bossParty, bossPartyName

  createBoss: (bossName, partyName) ->
    @game.bossFactory.createBoss bossName, partyName

  createBosses: (bossNames, partyName) ->
    _.map bossNames, (bossName) => @createBoss bossName, partyName

  bossBattleParty: (player, bossParty, name) ->

    startBattle = =>
      _.each player.party.players, (member) ->
        member.x = player.x
        member.y = player.y
        member.map = player.map

      _.each bossParty.players, (boss) ->
        boss.mirror player.party if boss.shouldMirror

      message = ">>> BOSS BATTLE: %player prepares for an epic battle against #{name}!"
      message = MessageCreator.doStringReplace message, player
      @game.broadcast MessageCreator.genericMessage message
      new Battle @game, [player.party, bossParty]

    # players need a party to get into combat
    if not player.party

      # we only give them an actual party if they're not too close to the bosses score
      if player.calc.totalItemScore() < bossParty.score() * 0.8
        @doEventForPlayer player.name, 'party'
        .then ->
          startBattle()
      else
        # otherwise they get a party of themselves
        new Party @game, [player]
        startBattle()

    else
      startBattle()

  # sendMessage = no implies that you're forwarding the original message to multiple people
  broadcastEvent: (options) ->
    {message, player, extra, sendMessage, type, link} = options
    sendMessage = yes if _.isUndefined sendMessage
    extra = {} if not extra

    # monsters can't receive messages :(
    return if player.isMonster

    if sendMessage
      message = MessageCreator.doStringReplace message, player, extra
      @game.broadcast MessageCreator.genericMessage message

    stripped = MessageCreator._replaceMessageColors message

    # pushbullet for the players!
    if link
      player.pushbulletSend extra.linkTitle, link
    else player.pushbulletSend stripped

    # cache all the things that happen
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
    player.recentEvents.unshift event
    player.recentEvents.pop() if player.recentEvents.length > Constants.defaults.player.maxRecentEvents

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
