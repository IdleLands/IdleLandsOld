
MessageCreator = require "../system/MessageCreator"
Player = require "../character/player/Player"

_ = require "underscore"
_.str = require "underscore.string"
chance = (new require "chance")()

class Battle
  constructor: (@game, @parties) ->
    return if @parties.length < 2
    @startBattle()
    @endBattle()

  startBattle: ->
    @setupParties()
    @initializePlayers()
    @beginTakingTurns()

  setupParties: ->
    _.each @parties, (party) =>
      party.currentBattle = @

  initializePlayers: ->
    @calculateTurnOrder()

    _.each @turnOrder, (player) ->
      player.recalculateStats()

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
    @emitEventToAll "battle.start", @turnOrder
    while @playersAlive()
      @turnPosition = @turnPosition or 0

      if @turnPosition is 0
        @game.broadcast MessageCreator.genericMessage "A new combat round has started. Current status: #{@getAllPlayerStatStrings().join ', '}"
        @emitEventToAll "round.start", @turnOrder

      @emitEventToAll "turn.start", player
      player = @turnOrder[@turnPosition]
      @takeTurn player
      @emitEventToAll "turn.end", player

      @turnPosition++
      if @turnPosition is @turnOrder.length
        @emitEventToAll "round.end", @turnOrder
        @turnPosition = 0

  takeTurn: (player) ->
    return if player.hp.atMin()
    if player.calc.cantAct() > 0
      affectingCauses = player.calc.cantActMessages()
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace "#{_.str.toSentence affectingCauses}!", player
      return

    availableSpells = @game.spellManager.getSpellsAvailableFor player
    spellChosen = _.sample availableSpells

    if chance.bool({likelihood: player.calc.physicalAttackChance()}) or availableSpells.length is 0
      @doPhysicalAttack player
    else
      @doMagicalAttack player, spellChosen

  doPhysicalAttack: (player, target = null) ->
    target = _.sample _.reject @turnOrder, ((target) -> ((player.party is target.party) or target.hp.atMin())) if not target
    return if not target

    message = "#{player.name} is attacking #{target.name}"

    [dodgeMin, dodgeMax] = [-target.calc.dodge(), player.calc.beatDodge()]

    dodgeChance = chance.integer {min: dodgeMin, max: dodgeMax}

    sendBattleMessage = (message, player) =>
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player

    if dodgeChance <= 0
      message += ", but #{target.name} dodged!"
      sendBattleMessage message, target
      @emitEvents "dodge", "dodged", target, player
      return

    [hitMin, hitMax] = [-target.calc.hit(), player.calc.beatHit()]

    hitChance = chance.integer {min: hitMin, max: hitMax}

    if hitChance is 0
      message += ", but #{player.name} missed!"
      sendBattleMessage message, target
      @emitEvents "miss", "missed", player, target
      return

    if hitChance < 0
      deflectItem = _.sample target.equipment
      message += ", but #{target.name} deflected it with %hisher #{deflectItem.getName()}!"
      sendBattleMessage message, target
      @emitEvents "deflect", "deflected", target, player
      return

    @emitEvents "target", "targeted", player, target

    damage = chance.integer {min: 1, max: player.calc.damage()}

    weapon = _.findWhere player.equipment, {type: "mainhand"}
    message += ", and hit with %hisher #{weapon.getName()} for #{damage} HP damage"

    @emitEvents "attack", "attacked", player, target
    @takeStatFrom player, target, damage, "physical", "hp"

    if target.hp.atMin()
      message += " -- a fatal blow!"
      @emitEvents "kill", "killed", player, target
    else
      message += "!"

    sendBattleMessage message, player

  doMagicalAttack: (player, spellClass) ->
    spell = @game.spellManager.modifySpell new spellClass @game, player
    spell.prepareCast()

  endBattle: ->
    @emitEventToAll "battle.end", @turnOrder
    randomWinningPlayer = _.sample(_.filter @turnOrder, (player) -> not player.hp.atMin())
    if not randomWinningPlayer
      @game.broadcast MessageCreator.genericMessage "Everyone died! The battle was a tie! You get nothing!"
      @cleanUp()
      return

    @winningParty = randomWinningPlayer.party
    winnerName = @winningParty.getPartyName()

    @losingPlayers  = _.difference @turnOrder, @winningParty.players

    @emitEventsTo "party.lose", @losingPlayers
    @emitEventsTo "party.win",  @winningParty.players

    @game.broadcast MessageCreator.genericMessage "The battle was won by #{winnerName}."

    @divvyXp()
    @cleanUp()

  divvyXp: ->
    deadVariables = {}
    deadVariables.deadPlayers = @losingPlayers
    deadVariables.numDead = deadVariables.deadPlayers.length
    deadVariables.deadPlayerTotalXp = _.reduce deadVariables.deadPlayers, ((prev, player) -> prev + player.xp.maximum), 0
    deadVariables.deadPlayerAverageXP = deadVariables.deadPlayerTotalXp / deadVariables.numDead
    deadVariables.winningParty = @winningParty

    winMessages = []
    loseMessages = []

    # winning player xp distribution
    _.each @winningParty.players, (player) ->
      xpGain = player.personalityReduce 'combatEndXpGain', [player, deadVariables], 0
      pct = +((xpGain/player.xp.maximum)*100).toFixed 3
      winMessages.push "#{player.name} gained #{xpGain}xp [#{pct}%]"

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence winMessages)+"!"

    _.each @winningParty.players, (player) ->
      xpGain = player.personalityReduce 'combatEndXpGain', [player, deadVariables], 0
      player.gainXp xpGain

    # end winning

    #losing player xp distribution

    _.each deadVariables.deadPlayers, (player) ->
      xpLoss = player.personalityReduce 'combatEndXpLoss', [player, deadVariables], 0
      pct = +((xpLoss/player.xp.maximum)*100).toFixed 3
      loseMessages.push "#{player.name} lost #{xpLoss}xp [#{pct}%]"

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence loseMessages)+"!"

    _.each deadVariables.deadPlayers, (player) ->
      xpLoss = player.personalityReduce 'combatEndXpLoss', [player, deadVariables], 0
      player.gainXp -xpLoss

    # end losing

  cleanUp: ->
    _.each @parties, (party) ->

      _.each party.players, (player) ->
        player.spellsAffectedBy = []

      delete party.currentBattle
      party.disband()

    @game.inBattle = false

  takeHp: (attacker, defender, damage, type, message) ->
    @takeStatFrom attacker, defender, damage, type, "hp", message

  takeMp: (attacker, defender, damage, type, message) ->
    @takeStatFrom attacker, defender, damage, type, "mp", message

  takeStatFrom: (attacker, defender, damage, type, damageType = "hp", message = null) ->

    damage -= defender.calc.damageTaken attacker, damage, type, damageType

    defender[damageType]?.sub damage

    if damageType is "hp"
      if damage < 0
        @emitEvents "heal", "healed", attacker, defender, type: type, damage: damage
      else
        @emitEvents "damage", "damaged", attacker, defender, type: type, damage: damage

      defender.spellsAffectedBy = [] if defender.hp.atMin()

    else if damageType is "mp"
      if damage < 0
        @emitEvents "energize", "energized", attacker, defender, type: type, damage: damage
      else
        @emitEvents "vitiate", "vitiated", attacker, defender, type: type, damage: damage

    @game.broadcast MessageCreator.genericMessage message if message and typeof message is "string"

  emitEventToAll: (event, data) ->
    _.forEach @turnOrder, (player) ->
      if player is data
        player.emit "self.#{event}", data
      else if data instanceof Player and player.party is data.party
        player.emit "ally.#{event}", data
      else if data instanceof Player and player.party isnt data.party
        player.emit "enemy.#{event}", data
      else
        player.emit event, data

  emitEventsTo: (event, to, data) ->
    _.forEach to, (player) ->
      player.emit event, data

  emitEvents: (attackerEvent, defenderEvent, attacker, defender, extra = {}) ->
    attacker.emit "self.#{attackerEvent}", defender, extra
    _.forEach (_.without attacker.party.players, attacker), (partyMate) ->
      partyMate.emit "ally.#{attackerEvent}", attacker, defender, extra

    _.forEach (_.intersection @turnOrder, attacker.party.players), (foe) ->
      foe.emit "enemy.#{attackerEvent}", attacker, defender, extra

    defender.emit "self.#{defenderEvent}", attacker, extra
    _.forEach (_.without defender.party.players, defender), (partyMate) ->
      partyMate.emit "ally.#{defenderEvent}", defender, attacker, extra

    _.forEach (_.intersection @turnOrder, defender.party.players), (foe) ->
      foe.emit "enemy.#{defenderEvent}", attacker, defender, extra

module.exports = exports = Battle