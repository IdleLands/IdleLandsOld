
MessageCreator = require "../system/MessageCreator"

_ = require "underscore"
chance = (new require "Chance")()

class Battle
  constructor: (@game, @parties) ->
    @startBattle()
    @endBattle()

  startBattle: ->
    @initializePlayers()
    @beginTakingTurns()

  initializePlayers: ->
    @calculateTurnOrder()

    _.each @turnOrder, (player) ->
      player.hp.toMaximum()
      player.mp.toMaximum()
      player.special.toMaximum()

  calculateTurnOrder: ->
    playerList = _.reduce @parties, ((prev, party) -> prev.concat party.players), []
    @turnOrder = _.sortBy playerList, (player) -> player.calc.stat 'agi'
    .reverse()

  getRelevantStats: (player) ->
    stats =
      name: player.name

    stats.hp = player.hp if player.hp.maximum isnt 0
    stats.mp = player.mp if player.mp.maximum isnt 0
    stats.special = player.special if player.special.maximum isnt 0

    stats

  stringifyStats: (stats) ->
    string = stats.name

    if stats.hp or stats.mp or stats.special
      string += " [ "
      string += "HP #{stats.hp.getValue()}/#{stats.hp.maximum} " if stats.hp
      string += "MP #{stats.mp.getValue()}/#{stats.mp.maximum} " if stats.mp
      string += "SP #{stats.sp.getValue()}/#{stats.sp.maximum} " if stats.sp
      string += "]"

    string

  getAllPlayerStatStrings: ->
    _.map @turnOrder, (player) =>
      @stringifyStats @getRelevantStats player

  playersAlive: ->
    #alivePlayers = _.reduce @turnOrder, ((count, player) -> count+(not player.hp.atMin())), 0
    parties = _.uniq _.pluck @turnOrder, 'party'
    aliveParties = _.reduce parties, (alive, party) ->
      currentAlive = _.reduce party.players, (count, player) ->
        count+(not player.hp.atMin())
      , 0
      alive.concat if currentAlive>0 then [party.name] else []
    , []

    1 < aliveParties.length

  beginTakingTurns: ->
    while @playersAlive()
      @turnPosition = @turnPosition or 0
      @turnPosition++

      #if @turnPosition is @turnOrder.length
        #console.log 'endround'

      @turnPosition = 0 if @turnPosition is @turnOrder.length

      if @turnPosition is 0
        @game.broadcast MessageCreator.genericMessage "A new combat round has started. Current status: #{@getAllPlayerStatStrings().join ', '}"

      player = @turnOrder[@turnPosition]
      @takeTurn player

  takeTurn: (player) ->
    return if player.hp.atMin()

    if chance.bool {likelihood: 100}
      @doPhysicalAttack player
    else
      console.log 'magic'
      # magical attack

  doPhysicalAttack: (player) ->
    target = _.sample _.reject @turnOrder, ((target) -> ((player.party is target.party) or target.hp.atMin()))
    return if not target

    message = "#{player.name} is attacking #{target.name}"

    dodgeChance = chance.integer {min: (-target.calc.dodge()), max: (player.calc.beatDodge())}

    #TODO maybe add a dodge percent so both conditions have to pass
    #dodge percent would only involve the target and it would probably be a 1-100 roll

    sendBattleMessage = (message, player) =>
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player

    if dodgeChance < 0
      message += ", but #{target.name} dodged!"
      sendBattleMessage message, target
      return

    hitChance = chance.integer {min: (-target.calc.hit()), max: (player.calc.beatHit())}

    if hitChance < 0
      deflectItem = _.sample target.equipment
      message += ", but #{target.name} deflected it with %hisher #{deflectItem.name}!"
      sendBattleMessage message, target
      return

    damage = chance.integer {min: 1, max: player.calc.damage()}

    weapon = _.findWhere player.equipment, {type: "mainhand"}
    message += ", and hit with %hisher #{weapon.name} for #{damage} HP damage"
    target.hp.sub damage

    if target.hp.atMin()
      message += " -- a fatal blow!"
    else
      message += "!"

    sendBattleMessage message, player

  endBattle: ->
    winningParty = _.sample(_.filter @turnOrder, (player) -> not player.hp.atMin()).party
    winnerName = if winningParty.players.size > 1 then winningParty.name else winningParty.players[0].name

    @game.broadcast MessageCreator.genericMessage "The battle was won by #{winnerName}."
    #divvy some bonus XP and such, as well as taking XP away from people who suck

    @game.inBattle = false

module.exports = exports = Battle