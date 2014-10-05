
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

      player.clearAffectingSpells()

      # somehow, I got NaN MP once, so this is to prevent misc. mistakes
      player.hp.__current = 0
      player.mp.__current = 0

      player.fled = false

      try
        player.hp?.toMaximum()
        player.mp?.toMaximum()
      catch e
        console.error e
        console.error "FAILED TO SET HP ???? #{player.name}"

  calculateTurnOrder: ->
    playerList = _.reduce @parties, ((prev, party) -> prev.concat party.players), []
    @turnOrder = _.sortBy playerList, (player) -> player.calc.stat 'agi'
                  .reverse()

  getRelevantStats: (player) ->
    stats =
      name: "<player.name>#{player.name}</player.name>"

    stats.hp = player.hp if player.hp.maximum isnt 0
    stats.mp = player.mp if player.mp.maximum isnt 0
    stats.special = player.special if player.special.maximum isnt 0

    stats

  stringifyStats: (player, stats) ->
    string = stats.name

    if stats.hp or stats.mp or stats.special

      if stats.hp.atMin()
        string += " [DEAD"

      else if player.fled
        string += " [FLED"

      else
        string += " [ "
        string += "<stats.hp>HP #{stats.hp.getValue()}/#{stats.hp.maximum}</stats.hp> " if stats.hp
        string += "<stats.mp>MP #{stats.mp.getValue()}/#{stats.mp.maximum}</stats.mp> " if stats.mp
        string += "<stats.sp>#{stats.special.name or "SP"} #{stats.special.getValue()}/#{stats.special.maximum}</stats.sp> " if stats.special
      string += "]"

    string

  getAllPlayersInPartyStatStrings: (party) ->
    _.map party.players, (player) =>
      @stringifyStats player, @getRelevantStats player

  getAllStatStrings: ->
    _.map @parties, (party) =>
      "#{(@getAllPlayersInPartyStatStrings party).join ', '}"

  playersAlive: ->
    parties = _.uniq _.pluck @turnOrder, 'party'
    aliveParties = _.reduce parties, (alive, party) ->
      currentAlive = _.reduce party.players, (count, player) ->
        count+((not player.hp.atMin()) and (not player.fled))
      , 0
      alive.concat if currentAlive>0 then [party.name] else []
    , []

    1 < aliveParties.length

  beginTakingTurns: ->
    @emitEventToAll "battle.start", @turnOrder
    while @playersAlive()
      @turnPosition = @turnPosition or 0

      if @turnPosition is 0
        @game.broadcast MessageCreator.genericMessage "ROUND STATUS: #{@getAllStatStrings().join ' VS '}"
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
    return if player.hp.atMin() or player.fled
    if player.calc.cantAct() > 0
      affectingCauses = player.calc.cantActMessages()
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace "#{_.str.toSentence affectingCauses}!", player
      return

    if chance.bool {likelihood: player.calc.fleePercent()}
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace "<player.name>#{player.name}</player.name> has fled from combat!", player
      player.fled = true
      @emitEventToAll "flee", player
      return

    availableSpells = @game.spellManager.getSpellsAvailableFor player
    spellChosen = _.sample availableSpells

    if chance.bool({likelihood: player.calc.physicalAttackChance()}) or availableSpells.length is 0
      @doPhysicalAttack player
    else
      @doMagicalAttack player, spellChosen

  doPhysicalAttack: (player, target = null, isCounter = no) ->
    target = _.sample _.reject @turnOrder, ((target) -> ((player.party is target.party) or target.hp.atMin() or target.fled)) if not target
    return if not target

    message = "<player.name>#{player.name}</player.name> is #{if isCounter then "COUNTER-" else ""}attacking <player.name>#{target.name}</player.name>"

    [dodgeMin, dodgeMax] = [-target.calc.dodge(), player.calc.beatDodge()]

    dodgeChance = chance.integer {min: dodgeMin, max: Math.max dodgeMin+1, dodgeMax}

    sendBattleMessage = (message, player) =>
      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player

    if dodgeChance <= 0
      message += ", but <player.name>#{target.name}</player.name> dodged!"
      sendBattleMessage message, target
      @emitEvents "dodge", "dodged", target, player
      return

    [hitMin, hitMax] = [-target.calc.hit(), player.calc.beatHit()]

    hitChance = chance.integer {min: hitMin, max: Math.max hitMin+1, hitMax}

    if -(target.calc.stat 'luck') <= hitChance <= 0
      message += ", but <player.name>#{player.name}</player.name> missed!"
      sendBattleMessage message, target
      @emitEvents "miss", "missed", player, target
      return

    if hitChance < -(target.calc.stat 'luck')
      deflectItem = _.sample target.equipment
      message += ", but <player.name>#{target.name}</player.name> deflected it with %hisher <event.item.#{deflectItem.itemClass}>#{deflectItem.getName()}</event.item.#{deflectItem.itemClass}>!"
      sendBattleMessage message, target
      @emitEvents "deflect", "deflected", target, player
      return

    @emitEvents "target", "targeted", player, target

    maxDamage = player.calc.damage()
    damage = chance.integer {min: player.calc.minDamage(), max: maxDamage}

    critRoll = chance.integer {min: 1, max: 10000}

    if critRoll <= player.calc.criticalChance()
      damage = maxDamage

    weapon = _.findWhere player.equipment, {type: "mainhand"}
    message += ", and #{if damage is maxDamage then "CRITICALLY " else ""}hit with %hisher <event.item.#{weapon.itemClass}>#{weapon.getName()}</event.item.#{weapon.itemClass}> for <damage.hp>#{damage}</damage.hp> HP damage"

    @emitEvents "attack", "attacked", player, target
    @emitEvents "critical", "criticalled", player, target if damage is maxDamage
    @takeStatFrom player, target, damage, "physical", "hp"
    @checkBattleEffects player, target

    fatal = no
    if target.hp.atMin()
      message += " -- a fatal blow!"
      fatal = yes

    else
      message += "!"

    sendBattleMessage message, player

    (@emitEvents "kill", "killed", player, target, {dead: target}) if fatal

  doMagicalAttack: (player, spellClass) ->
    spell = @game.spellManager.modifySpell new spellClass @game, player
    spell.prepareCast()

  checkBattleEffects: (attacker, defender) ->

    effects = []
    effects.push "Prone" if attacker.calc.prone() and chance.bool(likelihood: 15)
    return if effects.length is 0

    @doBattleEffects effects, attacker, defender

  doBattleEffects: (effects, attacker, defender) ->
    findSpell = (name) => _.findWhere @game.spellManager.spells, name: name

    eventMap =
      "Prone": ['effect.prone', 'effect.proned']

    _.each effects, (effect) =>
      spellProto = findSpell effect
      [aEvent, dEvent] = eventMap[effect]

      @emitEvents aEvent, dEvent, attacker, defender
      spellInst = new spellProto @game, attacker, defender
      spellInst.prepareCast()

  endBattle: ->
    @emitEventToAll "battle.end", @turnOrder
    randomWinningPlayer = _.sample(_.filter @turnOrder, (player) -> (not player.hp.atMin()) and (not player.fled))
    if not randomWinningPlayer
      @game.broadcast MessageCreator.genericMessage "Everyone died! The battle was a tie! You get nothing!"
      @cleanUp()
      return

    @winningParty = randomWinningPlayer.party
    winnerName = @winningParty.getPartyName()

    @losingPlayers  = _.reject (_.difference @turnOrder, @winningParty.players), (player) -> player.fled
    @winningParty.players = _.reject @winningParty.players, (player) -> player.fled

    @emitEventsTo "party.lose", @losingPlayers
    @emitEventsTo "party.win",  @winningParty.players

    @game.broadcast MessageCreator.genericMessage "The battle was won by <event.partyName>#{winnerName}</event.partyName>."

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

    xpMap = {}

    # winning player xp distribution
    _.each @winningParty.players, (player) ->
      return if player.isMonster
      basePct = chance.integer min: 1, max: 6
      basePctValue = Math.floor player.xp.maximum * (basePct/100)

      xpGain = player.personalityReduce 'combatEndXpGain', [player, deadVariables], basePctValue
      xpGain = player.calcXpGain xpGain

      gainPct = (xpGain/player.xp.maximum)*100
      pct = +((gainPct).toFixed 3)

      winMessages.push "<player.name>#{player.name}</player.name> gained <event.xp>#{xpGain}</event.xp>xp [<event.xp>#{pct}</event.xp>%]"

      xpMap[player] = xpGain

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence winMessages)+"!" if winMessages.length > 0

    _.each @winningParty.players, (player) ->
      player.gainXp xpMap[player]

    # winning player gold distribution

    winMessages = []

    _.each @winningParty.players, (player) ->
      return if player.isMonster

      goldGain = player.personalityReduce 'combatEndGoldGain', [player, deadVariables]
      goldGain = player.calcGoldGain goldGain

      player.gainGold goldGain

      winMessages.push "<player.name>#{player.name}</player.name> gained <event.gold>#{goldGain}</event.gold> gold" if goldGain

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence winMessages)+"!" if winMessages.length > 0

    # end winning

    #losing player xp distribution

    _.each deadVariables.deadPlayers, (player) ->
      return if player.isMonster
      basePct = chance.integer min: 1, max: 6
      basePctValue = Math.floor player.xp.maximum * (basePct/100)

      xpLoss = player.personalityReduce 'combatEndXpLoss', [player, deadVariables]
      xpLoss = player.calcXpGain xpLoss

      pct = +((xpLoss/player.xp.maximum)*100).toFixed 3
      loseMessages.push "<player.name>#{player.name}</player.name> lost <event.xp>#{xpLoss}</event.xp>xp [<event.xp>#{pct}</event.xp>%]"
      xpMap[player] = xpLoss

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence loseMessages)+"!" if loseMessages.length > 0

    _.each deadVariables.deadPlayers, (player) ->
      player.gainXp -xpMap[player]

    #losing player gold distribution

    loseMessages = []

    _.each deadVariables.deadPlayers, (player) ->
      return if player.isMonster

      goldLoss = player.personalityReduce 'combatEndGoldLoss', [player, deadVariables]
      goldLoss = player.calcGoldGain goldLoss

      player.gainGold -goldLoss

      loseMessages.push "<player.name>#{player.name}</player.name> lost <event.gold>#{goldLoss}</event.gold> gold" if goldLoss

    @game.broadcast MessageCreator.genericMessage (_.str.toSentence loseMessages)+"!" if loseMessages.length > 0

    # end losing

  cleanUp: ->
    _.each @parties, (party) ->

      _.each party.players, (player) ->
        player.clearAffectingSpells()

      party.disband()

    @game.inBattle = false

  takeHp: (attacker, defender, damage, type, spell, message) ->
    @takeStatFrom attacker, defender, damage, type, "hp", spell, message

  takeMp: (attacker, defender, damage, type, spell, message) ->
    @takeStatFrom attacker, defender, damage, type, "mp", spell, message

  takeStatFrom: (attacker, defender, damage, type, damageType = "hp", spell, message = null) ->

    damage -= defender.calc?.damageTaken attacker, damage, type, spell, damageType

    defender[damageType]?.sub damage

    if damageType is "hp"
      if damage < 0
        @emitEvents "heal", "healed", attacker, defender, type: type, damage: damage
      else
        @emitEvents "damage", "damaged", attacker, defender, type: type, damage: damage

      if defender.hp.atMin()
        defender.clearAffectingSpells()
        message = "#{message} [FATAL]" if message

    else if damageType is "mp"
      if damage < 0
        @emitEvents "energize", "energized", attacker, defender, type: type, damage: damage
      else
        @emitEvents "vitiate", "vitiated", attacker, defender, type: type, damage: damage

    extra =
      damage: Math.abs damage

    message = MessageCreator.doStringReplace message, attacker, extra
    @game.broadcast MessageCreator.genericMessage message if message and typeof message is "string"

  emitEventToAll: (event, data) ->
    _.forEach @turnOrder, (player) ->
      if player is data
        player.emit "combat.self.#{event}", data
      else if data instanceof Player and player.party is data.party
        player.emit "combat.ally.#{event}", data
      else if data instanceof Player and player.party isnt data.party
        player.emit "combat.enemy.#{event}", data
      else if event and event not in ['turn.end', 'turn.start']
        player.emit "combat.#{event}", data

  emitEventsTo: (event, to, data) ->
    _.forEach to, (player) ->
      player.emit "combat.#{event}", data

  emitEvents: (attackerEvent, defenderEvent, attacker, defender, extra = {}) ->
    return if (not defender) or (not attacker)
    attacker.emit "combat.self.#{attackerEvent}", defender, extra
    _.forEach (_.without attacker.party.players, attacker), (partyMate) ->
      partyMate.emit "combat.ally.#{attackerEvent}", attacker, defender, extra

    _.forEach (_.intersection @turnOrder, attacker.party.players), (foe) ->
      foe.emit "combat.enemy.#{attackerEvent}", attacker, defender, extra

    defender.emit "combat.self.#{defenderEvent}", attacker, extra
    _.forEach (_.without defender.party.players, defender), (partyMate) ->
      partyMate.emit "combat.ally.#{defenderEvent}", defender, attacker, extra

    _.forEach (_.intersection @turnOrder, defender.party.players), (foe) ->
      foe.emit "combat.enemy.#{defenderEvent}", attacker, defender, extra

module.exports = exports = Battle
