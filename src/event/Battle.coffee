
MessageCreator = require "../system/MessageCreator"

_ = require "underscore"
_.str = require "underscore.string"
chance = (new require "chance")()

# TODO
# TODO
# TODO
# emit events & more stat calculations like hp / mp

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

      player.hp.maximum = player.calc.hp()
      player.mp.maximum = player.calc.mp()
      player.special.maximum = player.calc.special()

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
      string += "SP #{stats.special.getValue()}/#{stats.special.maximum} " if stats.special
      string += "]"

    string

  getAllPlayerStatStrings: ->
    _.map @turnOrder, (player) =>
      @stringifyStats @getRelevantStats player

  playersAlive: ->
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

      if @turnPosition is 0
        @game.broadcast MessageCreator.genericMessage "A new combat round has started. Current status: #{@getAllPlayerStatStrings().join ', '}"

      player = @turnOrder[@turnPosition]
      @takeTurn player

      @turnPosition++
      if @turnPosition is @turnOrder.length
        #end round
        @turnPosition = 0

  takeTurn: (player) ->
    return if player.hp.atMin()

    if chance.bool {likelihood: player.calc.physicalAttackChance()}
      @doPhysicalAttack player
    else
      console.log 'magic'
      # magical attack

  doPhysicalAttack: (player) ->
    target = _.sample _.reject @turnOrder, ((target) -> ((player.party is target.party) or target.hp.atMin()))
    return if not target

    message = "#{player.name} is attacking #{target.name}"

    [dodgeMin, dodgeMax] = [-target.calc.dodge(), player.calc.beatDodge()]

    dodgeChance = chance.integer {min: dodgeMin, max: dodgeMax}

    #TODO maybe add a dodge percent so both conditions have to pass
    #dodge percent would only involve the target and it would probably be a 1-100 roll

    sendBattleMessage = (message, player) =>
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player

    if dodgeChance <= 0
      message += ", but #{target.name} dodged!"
      sendBattleMessage message, target
      return

    [hitMin, hitMax] = [-target.calc.hit(), player.calc.beatHit()]

    hitChance = chance.integer {min: hitMin, max: hitMax}

    if hitChance <= 0
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
    randomWinningPlayer = _.sample(_.filter @turnOrder, (player) -> not player.hp.atMin())
    if not randomWinningPlayer
      @game.broadcast MessageCreator.genericMessage "Everyone died! The battle was a tie! You get nothing!"
      @cleanUp()
      return

    @winningParty = randomWinningPlayer.party
    winnerName = if @winningParty.players.size > 1 then @winningParty.name else @winningParty.players[0].name

    @game.broadcast MessageCreator.genericMessage "The battle was won by #{winnerName}."

    @divvyXp()
    @cleanUp()

  divvyXp: ->
    deadVariables = {}
    deadVariables.deadPlayers = _.filter @turnOrder, (player) -> player.hp.atMin() and (player.party isnt @winningParty)
    deadVariables.numDead = deadVariables.deadPlayers.length
    deadVariables.deadPlayerTotalXp = _.reduce deadVariables.deadPlayers, ((prev, player) -> prev + player.xp.maximum), 0
    deadVariables.deadPlayerAverageXP = deadVariables.deadPlayerTotalXp / deadVariables.numDead
    deadVariables.winningParty = @winningParty

    winMessages = []
    loseMessages = []
    _.each @winningParty.players, (player) =>
      xpGain = player.personalityReduce 'combatEndXpGain', [player, deadVariables], 0
      winMessages.push "#{player.name} gained #{xpGain}xp"
      player.gainXp xpGain

    _.each deadVariables.deadPlayers, (player) =>
      xpLoss = player.personalityReduce 'combatEndXpLoss', [player, deadVariables], 0
      loseMessages.push "#{player.name} lost #{xpLoss}xp"
      player.gainXp -xpLoss

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence winMessages)+"!"
    @game.broadcast MessageCreator.genericMessage (_.str.toSentence loseMessages)+"!"

  cleanUp: ->
    _.each @parties, (party) ->
      party.disband()

    @game.inBattle = false

module.exports = exports = Battle