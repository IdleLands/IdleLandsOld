
MessageCreator = require "../system/handlers/MessageCreator"
Player = require "../character/player/Player"
Character = require "../character/base/Character"
BattleCache = require "./BattleCache"
Constants = require "../system/utilities/Constants"

_ = require "lodash"
_.str = require "underscore.string"
chance = (new require "chance")()

class Battle

  BAD_TURN_THRESHOLD: 100
  BAD_ROUND_THRESHOLD: 300

  constructor: (@game, @parties, @event, @suppress = Constants.defaults.battle.suppress, @battleUrl = Constants.defaults.battle.showUrl) ->
    return if @parties.length < 2
    @game.battle = @
    @logger = @game.logManager.getLogger "Battle"
    @startBattle()

    @logger?.warn "constructor is bad!" if @isBad
    return @cleanUpGlobals() if @isBad

    @endBattle()

  startBattle: ->
    @logger?.info "BATTLE START"
    @setupParties()

    @logger?.warn "startBattle is bad!" if @isBad
    return if @isBad

    @badTurns = 0
    @battleCache = new BattleCache @game, @parties

    @broadcast MessageCreator.genericMessage MessageCreator.doStringReplace @event.remark, @event.player if @event

    @game.currentBattle = @
    @initializePlayers()
    @link = Constants.defaults.battle.urlFormat.replace /%name/g, @battleCache.name.split(' ').join("%20")
    @playerNames = @getAllPlayerNames()
    @startMessage() if @suppress
    @beginTakingTurns()

  startMessage: ->
    if @battleUrl
      message = ">>> BATTLE: #{@battleCache.name} has occurred involving #{@playerNames}. Check it out here: #{@link}"
    else message = "#{@getAllStatStrings().join ' VS '}"
    @broadcast message, {}, yes, no

  setupParties: ->
    _.each @parties, (party) =>
      if not party or party.players.length is 0
        @game.errorHandler.captureException new Error "INVALID PARTY ??? ABORTING"
        console.error @parties
        @isBad = yes
        return

      party.currentBattle = @

  fixStats: ->
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
        @game.errorHandler.captureException e

  initializePlayers: ->
    @calculateTurnOrder()
    @fixStats()

  calculateTurnOrder: ->
    playerList = _.reduce @parties, ((prev, party) -> prev.concat party.players), []
    @turnOrder = _.sortBy playerList, (player) -> player.calc.stat 'agi'
                  .reverse()
    @logger?.info "battle order", {turnOrder: @turnOrder}

  getRelevantStats: (player) ->
    stats =
      name: "<player.name>#{player.getName()}</player.name>"

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
        string += "<stats.sp>#{stats.special.name} #{stats.special.getValue()}/#{stats.special.maximum}</stats.sp> " if stats.special?.name
      string += "]"

    string

  getAllPlayerNames: ->
    names = _.map @parties, (party) => @getAllPlayersInPartyNames party
    _.str.toSentenceSerial _.flatten names

  getAllPlayersInPartyNames: (party) ->
    _.map party.players, (player) -> "<player.name>#{player.getName()}</player.name>"

  getAllPlayersInPartyStatStrings: (party) ->
    _.map party.players, (player) =>
      @stringifyStats player, @getRelevantStats player

  getAllStatStrings: ->
    _.map @parties, (party) =>
      "#{(@getAllPlayersInPartyStatStrings party).join ', '}"

  broadcast: (message, player = {}, ignoreSuppress = no, postToCache = yes) ->
    @battleCache.addMessage message if postToCache
    return if @suppress and not ignoreSuppress
    message = MessageCreator.genericMessage message, player
    @game.broadcast message

  playersAlive: ->
    parties = _.uniq _.pluck @turnOrder, 'party'
    aliveParties = _.reduce parties, (alive, party) ->
      currentAlive = _.reduce party?.players, (count, player) ->
        count+((not player.hp.atMin()) and (not player.fled))
      , 0
      alive.concat if currentAlive>0 then [party.name] else []
    , []

    1 < aliveParties.length

  checkIfOpponentHasBattleEffect: (turntaker, effect) ->
    0 < _.reduce (_.difference @turnOrder, turntaker.party?.players), ((prev, player) -> prev+player.calc[effect]()), 0

  beginTakingTurns: ->
    @logger?.info "battle.start"

    ##TAG:EVENT_COMBAT: battle.start | turnorder | Emitted when the battle starts
    @emitEventToAll "battle.start", null, [@turnOrder]
    @currentTurn = 1
    while @playersAlive()
      @turnPosition = @turnPosition or 0

      return if @badTurns > @BAD_TURN_THRESHOLD
      return if @currentTurn > @BAD_ROUND_THRESHOLD

      if @turnPosition is 0
        @broadcast "ROUND #{@currentTurn} STATUS: #{@getAllStatStrings().join ' VS '}"
        @logger?.info "round.start"

        ##TAG:EVENT_COMBAT: round.start | turnorder | Emitted when a new round starts
        @emitEventToAll "round.start", null, [@turnOrder]

      player = @turnOrder[@turnPosition]
      @logger?.verbose "turn.start", {player: player}

      ##TAG:EVENT_COMBAT: [sea].turn.start | player | Emitted when a player takes a turn
      @emitEventToAll "turn.start", player, [player]
      @takeTurn player

      ##TAG:EVENT_COMBAT: [sea].turn.end | player | Emitted when a player ends a turn
      @emitEventToAll "turn.end", player, [player]
      @logger?.verbose "turn.end", {player: player}

      @turnPosition++
      if @turnPosition is @turnOrder.length
        @logger?.info "round.end"

        ##TAG:EVENT_COMBAT: round.end | turnorder | Emitted when the round is over
        @emitEventToAll "round.end", null, [@turnOrder]
        @turnPosition = 0
        @currentTurn++

  takeTurn: (player) ->
    return if player.hp.atMin() or player.fled

    player.hp.add player.calc.stat "hpregen"
    player.mp.add player.calc.stat "mpregen"

    if (@checkIfOpponentHasBattleEffect player, "mindwipe") and (chance.bool {likelihood: 1})
      @broadcast "#{player.getName()} was attacked by mindwipe! All personalities have now been turned off!"
      player.removeAllPersonalities()
      return

    if @currentTurn is 1 and @checkIfOpponentHasBattleEffect player, "startle"
      message = "#{player.getName()} is startled!"
      @broadcast message

      ##TAG:EVENT_COMBAT: [sea].startled | player | Emitted when a player gets startled
      @emitEventToAll "startled", player, [player]
      return

    if player.calc.cantAct() > 0
      affectingCauses = player.calc.cantActMessages()
      message = MessageCreator.doStringReplace "#{_.str.toSentence affectingCauses}!", player
      @broadcast message
      return

    if (chance.bool {likelihood: player.calc.fleePercent()}) and not @checkIfOpponentHasBattleEffect player, "fear"
      @broadcast "<player.name>#{player.getName()}</player.name> has fled from combat!", player
      player.fled = true

      ##TAG:EVENT_COMBAT: [sea].flee | player | Emitted when a player flees combat
      @emitEventToAll "flee", player, [player]
      return

    availableSpells = @game.spellManager.getSpellsAvailableFor player
    spellChosen = _.sample availableSpells

    if chance.bool({likelihood: player.calc.physicalAttackChance()}) or availableSpells.length is 0
      @doPhysicalAttack player
    else
      @doMagicalAttack player, spellChosen

  tryParry: (defender, attacker) ->
    defenderParry = defender.calc.parry()
    parryChance = Math.max 0, Math.min 100, 100 - defenderParry*10
    return if (chance.bool {likelihood: parryChance})

    @doPhysicalAttack defender, attacker, yes

  doPhysicalAttack: (player, target = null, isCounter = no) ->
    if not target
      enemies = _.reject @turnOrder, (target) -> (player.party is target.party) or target.hp.atMin() or target.fled
      targets = player.calc.physicalAttackTargets enemies, @turnOrder
      target = _.sample targets

    return if not target

    battleMessage = (message, player) =>
      @broadcast MessageCreator.doStringReplace message, player

    message = "<player.name>#{player.getName()}</player.name> is #{if isCounter then "COUNTER-" else ""}attacking <player.name>#{target.name}</player.name>"

    [dodgeMin, dodgeMax] = [-target.calc.dodge(), player.calc.beatDodge()]

    dodgeChance = chance.integer {min: dodgeMin, max: Math.max dodgeMin+1, dodgeMax}

    if dodgeChance <= 0
      message += ", but <player.name>#{target.getName()}</player.name> dodged!"
      battleMessage message, target

      ##TAG:EVENT_COMBAT: [sea].dodge  | attacked, attacker | Emitted when a player (`attacked`) dodges an attack
      ##TAG:EVENT_COMBAT: [sea].dodged | attacked, attacker | Emitted when a player (`attacker`) is dodged
      @emitEvents "dodge", "dodged", target, player
      @tryParry target, player
      @badTurns++
      return

    [hitMin, hitMax] = [-target.calc.hit(), player.calc.beatHit()]

    hitChance = chance.integer {min: hitMin, max: Math.max hitMin+1, hitMax}

    if -(target.calc.stat 'luck') <= hitChance <= 0
      message += ", but <player.name>#{player.getName()}</player.name> missed!"
      battleMessage message, target

      ##TAG:EVENT_COMBAT: [sea].miss   | attacker, attacked | Emitted when a player (`attacker`) misses an attack
      ##TAG:EVENT_COMBAT: [sea].missed | attacker, attacked | Emitted when a player (`attacked`) is missed
      @emitEvents "miss", "missed", player, target
      @tryParry target, player
      @badTurns++
      return

    if hitChance < -(target.calc.stat 'luck')
      deflectItem = _.sample target.equipment
      message += ", but <player.name>#{target.name}</player.name> deflected it with %hisher <event.item.#{deflectItem.itemClass}>#{deflectItem.getName()}</event.item.#{deflectItem.itemClass}>!"
      battleMessage message, target

      ##TAG:EVENT_COMBAT: [sea].deflect   | attacked, attacker | Emitted when a player (`attacked`) deflects an attack
      ##TAG:EVENT_COMBAT: [sea].deflected | attacked, attacker | Emitted when a player (`attacker`) is deflected
      @emitEvents "deflect", "deflected", target, player
      @tryParry target, player
      @badTurns++
      return

    maxDamage = player.calc.damage()
    damage = chance.integer {min: player.calc.minDamage(), max: maxDamage}

    critRoll = chance.integer {min: 1, max: 10000}

    if critRoll <= player.calc.criticalChance() and not target.calc.aegis()
      damage = maxDamage

    if damage is maxDamage and player.calc.lethal()
      damage *= 1.5

    damage = target.calcDamageTaken damage

    damageType = if damage < 0 then "healing" else "damage"
    realDamage = Math.round Math.abs damage

    weapon = _.findWhere player.equipment, {type: "mainhand"}
    weapon = {itemClass: "basic", getName: -> return "claw"} if not weapon
    message += ", and #{if damage is maxDamage then "CRITICALLY " else ""}hit with %hisher <event.item.#{weapon.itemClass}>#{weapon.getName()}</event.item.#{weapon.itemClass}> for <damage.hp>#{realDamage}</damage.hp> HP #{damageType}"

    fatal = no
    if target.hp.getValue() - damage <= 0 and not target.calc.sturdy()
      message += " -- a fatal blow!"
      fatal = yes
      
    else if target.hp.getValue() is 1 and target.calc.sturdy() and target.hp.gtePercent 10
      message += " -- a nearly fatal blow!"

    else
      message += "!"

    battleMessage message, player

    @takeStatFrom player, target, damage, "physical", "hp"

    @checkBattleEffects player, target if not fatal

    ##TAG:EVENT_COMBAT: [sea].target   | attacker, attacked | Emitted when a player (`attacker`) targets `attacked`
    ##TAG:EVENT_COMBAT: [sea].targeted | attacker, attacked | Emitted when a player (`attacked`) is targetted
    @emitEvents "target", "targeted", player, target


    ##TAG:EVENT_COMBAT: [sea].target   | attacker, attacked | Emitted when a player (`attacker`) attacks `attacked`
    ##TAG:EVENT_COMBAT: [sea].targeted | attacker, attacked | Emitted when a player (`attacked`) is attacked
    @emitEvents "attack", "attacked", player, target

    ##TAG:EVENT_COMBAT: [sea].critical    | attacker, attacked | Emitted when a player (`attacker`) scores a critical hit on `attacked`
    ##TAG:EVENT_COMBAT: [sea].criticalled | attacker, attacked | Emitted when a player (`attacked`) is hit by a critical hit
    @emitEvents "critical", "criticalled", player, target if damage is maxDamage

    ##TAG:EVENT_COMBAT: [sea].kill   | attacker, attacked, {dead} | Emitted when a player (`attacker`) scores a lethal blow on `attacked`
    ##TAG:EVENT_COMBAT: [sea].killed | attacker, attacked, {dead} | Emitted when a player (`attacked`) is killed
    (@emitEvents "kill", "killed", player, target, {dead: target}) if fatal

  doMagicalAttack: (player, spellClass) ->
    spell = @game.spellManager.modifySpell new spellClass @game, player
    spell.prepareCast()

  checkBattleEffects: (attacker, defender) ->

    effects = []
    effects.push "Prone"    if attacker.calc.prone() and chance.bool(likelihood: attacker.calc.proneChance())
    effects.push "Shatter"  if attacker.calc.shatter() and chance.bool(likelihood: attacker.calc.shatterChance())
    effects.push "Poison"   if attacker.calc.poison() and chance.bool(likelihood: attacker.calc.poisonChance())
    effects.push "Venom"    if attacker.calc.venom() and chance.bool(likelihood: attacker.calc.venomChance())
    effects.push "Vampire"  if attacker.calc.vampire() and chance.bool(likelihood: attacker.calc.vampireChance())
    return if effects.length is 0

    @doBattleEffects effects, attacker, defender

  doBattleEffects: (effects, attacker, defender) ->
    findSpell = (name) => _.findWhere @game.spellManager.spells, name: name

    eventMap =
      ##TAG:EVENT_COMBAT: [sea].effect.prone  | attacker, attacked | Emitted when a player (`attacker`) prones `attacked`
      ##TAG:EVENT_COMBAT: [sea].effect.proned | attacker, attacked | Emitted when a player (`attacked`) is knocked prone
      "Prone":   ['effect.prone', 'effect.proned']

      ##TAG:EVENT_COMBAT: [sea].effect.shatter   | attacker, attacked | Emitted when a player (`attacker`) shatters `attacked`s defenses
      ##TAG:EVENT_COMBAT: [sea].effect.shattered | attacker, attacked | Emitted when a player (`attacked`) has defenses shattered
      "Shatter": ['effect.shatter', 'effect.shattered']

      ##TAG:EVENT_COMBAT: [sea].effect.poison   | attacker, attacked | Emitted when a player (`attacker`) poisons `attacked`
      ##TAG:EVENT_COMBAT: [sea].effect.poisoned | attacker, attacked | Emitted when a player (`attacked`) is poisoned
      "Poison":  ['effect.poison', 'effect.poisoned']

      ##TAG:EVENT_COMBAT: [sea].effect.venom   | attacker, attacked | Emitted when a player (`attacker`) venoms `attacked`
      ##TAG:EVENT_COMBAT: [sea].effect.venomed | attacker, attacked | Emitted when a player (`attacked`) is venomed
      "Venom":   ['effect.venom', 'effect.venomed']

      ##TAG:EVENT_COMBAT: [sea].effect.vampire  | attacker, attacked | Emitted when a player (`attacker`) vampires `attacked`
      ##TAG:EVENT_COMBAT: [sea].effect.vampired | attacker, attacked | Emitted when a player (`attacked`) is vampired
      "Vampire": ['effect.vampire', 'effect.vampired']

    _.each effects, (effect) =>
      spellProto = findSpell effect
      [aEvent, dEvent] = eventMap[effect]

      @emitEvents aEvent, dEvent, attacker, defender
      spellInst = new spellProto @game, attacker, defender
      spellInst.prepareCast()

  endBattle: ->

    if @badTurns > @BAD_TURN_THRESHOLD or @currentTurn >= @BAD_ROUND_THRESHOLD

      ##TAG:EVENT_COMBAT: battle.stale | turnorder | Emitted when a battle goes stale
      @emitEventToAll "battle.stale", null, [@turnOrder]
      @broadcast "Thalynas, The Goddess of Destruction And Stopping Battles Prematurely decided that you mortals were taking too long. Try better to amuse her next time!", {}, not @battleUrl
      @cleanUp()
      return

    ##TAG:EVENT_COMBAT: battle.end | turnorder | Emitted when a battle ends properly
    @emitEventToAll "battle.end", null, [@turnOrder]
    randomWinningPlayer = _.sample(_.filter @turnOrder, (player) -> (not player.hp.atMin()) and (not player.fled))
    if not randomWinningPlayer

      if @turnOrder.length is 0 or @parties.length is 0
        @game.errorHandler.captureException (new Error "Bad Battle Ending"), extra: toLength: @turnOrder.length, plLength: @parties.length

      @broadcast "Everyone died! The battle was a tie! You get nothing!", {}, not @battleUrl
      @cleanUp()
      return

    @winningParty = randomWinningPlayer.party
    winnerName = @winningParty.getPartyName()

    @losingPlayers  = _.reject (_.difference @turnOrder, @winningParty.players), (player) -> player.fled
    @winningParty.players = _.reject @winningParty.players, (player) -> player.fled

    ##TAG:EVENT_COMBAT: party.lose | losers, winners | Emitted when a party loses combat
    @emitEventsTo "party.lose", @losingPlayers, @winningParty.players

    ##TAG:EVENT_COMBAT: party.win  | winners, losers | Emitted when a party wins combat
    @emitEventsTo "party.win",  @winningParty.players, @losingPlayers

    @broadcast "The battle was won by <event.partyName>#{winnerName}</event.partyName>.", {}, not @battleUrl

    @divvyXp()
    @cleanUp()

  notifyParticipants: (e, docs) ->

    @game.errorHandler.captureException e if e

    players = _.reject @turnOrder, (member) -> member.isMonster
    _.each players, (player) =>
      @game.eventHandler.broadcastEvent
        sendMessage: no
        extra: {battleId: docs?[0]._id, linkTitle: @battleCache.name}
        player: player
        message: ">>> BATTLE: #{@battleCache.name} has occurred involving #{@playerNames}. Check it out here: #{@link}"
        type: "combat"
        link: @link

  divvyXp: ->
    deadVariables = {}
    deadVariables.deadPlayers = _.where @losingPlayers, {fled: false}
    deadVariables.numDead = deadVariables.deadPlayers.length
    deadVariables.deadPlayerTotalXp = _.reduce deadVariables.deadPlayers, ((prev, player) -> prev + player.xp.maximum), 0
    deadVariables.deadPlayerAverageXP = deadVariables.deadPlayerTotalXp / deadVariables.numDead
    deadVariables.winningParty =  @winningParty
    combatWinners = _.where deadVariables.winningParty.players, {fled: false}

    winMessages = []
    loseMessages = []

    xpMap = {}

    # winning player xp distribution
    _.each combatWinners, (player) ->
      return if player.isMonster
      basePct = chance.integer min: 1, max: Math.max 1, 6+player.calc.royal()
      basePctValue = Math.floor player.xp.maximum * (basePct/100)

      xpGain = player.personalityReduce 'combatEndXpGain', [player, deadVariables], basePctValue
      xpGain = player.calcXpGain xpGain

      gainPct = (xpGain/player.xp.maximum)*100
      pct = +((gainPct).toFixed 3)

      winMessages.push "<player.name>#{player.getName()}</player.name> gained <event.xp>#{xpGain}</event.xp>xp [<event.xp>#{pct}</event.xp>%]"

      xpMap[player] = xpGain

    @broadcast (_.str.toSentence winMessages)+"!", {}, not @battleUrl if winMessages.length > 0

    _.each combatWinners, (player) ->
      player.gainXp xpMap[player]

    # winning player gold distribution

    winMessages = []

    _.each combatWinners, (player) ->
      return if player.isMonster and not player.isPet

      goldGain = player.personalityReduce 'combatEndGoldGain', [player, deadVariables]
      goldGain = player.calcGoldGain goldGain

      if goldGain > 0
        player.gainGold goldGain
        winMessages.push "<player.name>#{player.getName()}</player.name> gained <event.gold>#{goldGain}</event.gold> gold"

    @broadcast (_.str.toSentence winMessages)+"!", {}, not @battleUrl if winMessages.length > 0

    # end winning

    #losing player xp distribution

    _.each deadVariables.deadPlayers, (player) ->
      return if player.isMonster and not player.isPet
      basePct = chance.integer min: 1, max: 6
      basePctValue = Math.floor player.xp.maximum * (basePct/100)

      xpLoss = player.personalityReduce 'combatEndXpLoss', [player, deadVariables], basePctValue
      xpLoss = player.calcXpGain xpLoss

      pct = +((xpLoss/player.xp.maximum)*100).toFixed 3
      loseMessages.push "<player.name>#{player.getName()}</player.name> lost <event.xp>#{xpLoss}</event.xp>xp [<event.xp>#{pct}</event.xp>%]"
      xpMap[player] = xpLoss

    @broadcast (_.str.toSentence loseMessages)+"!", {}, not @battleUrl if loseMessages.length > 0

    _.each deadVariables.deadPlayers, (player) ->
      player.gainXp -xpMap[player]

    #losing player gold distribution

    loseMessages = []

    _.each deadVariables.deadPlayers, (player) ->
      return if player.isMonster

      goldLoss = player.personalityReduce 'combatEndGoldLoss', [player, deadVariables]
      goldLoss = player.calcGoldGain goldLoss

      if goldLoss > 0
        player.gainGold -goldLoss
        loseMessages.push "<player.name>#{player.getName()}</player.name> lost <event.gold>#{goldLoss}</event.gold> gold"

    @broadcast (_.str.toSentence loseMessages)+"!", {}, not @battleUrl if loseMessages.length > 0

    # end losing

  cleanUp: ->
    _.each @parties, (party) =>

      _.each party.players, (player) ->
        player.clearAffectingSpells()

      if party.isMonsterParty or party.shouldDisband (if party is @winningParty then 25 else 50)
        party.disband()

      else
        party.finishAfterBattle()

    @cleanUpGlobals()
    @fixStats()

    @battleCache.finalize @notifyParticipants.bind @
    @game.currentBattle = null

  cleanUpGlobals: ->
    @game.battle = null
    @game.inBattle = false

  takeHp: (attacker, defender, damage, type, spell, message) ->
    @takeStatFrom attacker, defender, damage, type, "hp", spell, message

  takeMp: (attacker, defender, damage, type, spell, message) ->
    @takeStatFrom attacker, defender, damage, type, "mp", spell, message

  takeStatFrom: (attacker, defender, damage, type, damageType = "hp", spell, message = null, doPropagate = no) ->

    damage += attacker.calc.absolute()

    darksideDamage = Math.round damage*(attacker.calc.darkside()*3/100)
    damage += darksideDamage if darksideDamage > 0

    damage -= defender.calc?.damageTaken attacker, damage, type, spell, damageType

    damage = Math.round damage

    canFireSturdy = defender.hp.gtePercent 10

    defender[damageType]?.sub damage
    defenderPunishDamage = if damage > 0 then Math.round damage*(defender.calc.punish()*5/100) else 0

    if damageType is "hp"
      if damage < 0

        ##TAG:EVENT_COMBAT: [sea].heal   | attacker, defender, {type, damage} | Emitted when a player (`attacker`) heals `defender` (hp)
        ##TAG:EVENT_COMBAT: [sea].healed | attacker, defender, {type, damage} | Emitted when a player (`defender`) is healed (hp)
        @emitEvents "heal", "healed", attacker, defender, type: type, damage: damage
      else

        ##TAG:EVENT_COMBAT: [sea].damage  | attacker, defender, {type, damage} | Emitted when a player (`attacker`) damages `defender` (hp)
        ##TAG:EVENT_COMBAT: [sea].damaged | attacker, defender, {type, damage} | Emitted when a player (`defender`) is damaged (hp)
        @emitEvents "damage", "damaged", attacker, defender, type: type, damage: damage

      if defender.calc.sturdy() and defender.hp.atMin() and canFireSturdy

        ##TAG:EVENT_COMBAT: [sea].effect.sturdy | player | Emitted when a player triggers sturdy
        @emitEventToAll "effect.sturdy", defender, [defender]
        defender.hp.set 1
        message = "#{message} [STURDY]" if message

      if defender.hp.atMin()
        defender.clearAffectingSpells()
        message = "#{message} [FATAL]" if message

      if damage is 0
        @badTurns++
      else
        @badTurns = 0

    else if damageType is "mp"
      if damage < 0

        ##TAG:EVENT_COMBAT: [sea].energize  | attacker, defender, {type, damage} | Emitted when a player (`attacker`) healed `defender` (mp)
        ##TAG:EVENT_COMBAT: [sea].energized | attacker, defender, {type, damage} | Emitted when a player (`defender`) is healed (mp)
        @emitEvents "energize", "energized", attacker, defender, type: type, damage: damage
      else

        ##TAG:EVENT_COMBAT: [sea].vitiate  | attacker, defender, {type, damage} | Emitted when a player (`attacker`) attacked `defender` (mp)
        ##TAG:EVENT_COMBAT: [sea].vitiated | attacker, defender, {type, damage} | Emitted when a player (`defender`) is attacked (mp)
        @emitEvents "vitiate", "vitiated", attacker, defender, type: type, damage: damage

    extra =
      damage: Math.abs damage

    message = MessageCreator.doStringReplace message, attacker, extra
    @broadcast message if message and typeof message is "string"

    if defenderPunishDamage > 0 and not doPropagate and not attacker.hp.atMin() and attacker isnt defender
      refmsg = "<player.name>#{defender.name}</player.name> reflected <damage.hp>#{defenderPunishDamage}</damage.hp> damage back at <player.name>#{attacker.name}</player.name>!"
      @takeStatFrom defender, attacker, defenderPunishDamage, type, damageType, spell, refmsg, yes

      ##TAG:EVENT_COMBAT: effect.punish.damage   | attacker, defender, {damage} | Emitted when a defender hits an attacker with punish damage
      ##TAG:EVENT_COMBAT: effect.punished.damage | attacker, defender, {damage} | Emitted when an attacker is punished by a defender
      @emitEvents "effect.punish", "effect.punished", defender, attacker, {damage: defenderPunishDamage}

    if darksideDamage > 0 and not doPropagate and not attacker.hp.atMin() and attacker isnt defender
      refmsg = "<player.name>#{attacker.name}</player.name> took <damage.hp>#{darksideDamage}</damage.hp> damage due to darkside!"
      @takeStatFrom attacker, attacker, darksideDamage, type, damageType, spell, refmsg, yes

      ##TAG:EVENT_COMBAT: effect.darkside | attacker, darksideDamage | Emitted when an attacker deals darkside damage to itself
      @emitEventToAll "effect.darkside", attacker, [attacker, darksideDamage]

  emitEventToAll: (event, context, data = []) ->
    _.each @turnOrder, (player) ->
      if (context instanceof Character)
        emitted = no
        if not emitted and player is context
          emitted = yes
          player.emit.apply player, ["combat.self.#{event}"].concat data

        if not emitted and player.party is data?
          emitted = yes
          player.emit.apply player, ["combat.ally.#{event}"].concat data

        if not emitted and player.party isnt data?.party
          emitted = yes
          player.emit.apply player, ["combat.enemy.#{event}"].concat data

      else
        player.emit.apply player, ["combat.#{event}"].concat data

  emitEventsTo: (event, to, data) ->
    _.each to, (player) ->
      player.emit "combat.#{event}", data

  emitEvents: (attackerEvent, defenderEvent, attacker, defender, extra = {}) ->
    return if (not defender) or (not attacker) or (not defender.party) or (not attacker.party)
    _.each (_.without attacker.party.players, attacker), (partyMate) ->
      partyMate.emit "combat.ally.#{attackerEvent}", attacker, defender, extra

    _.each (_.intersection @turnOrder, attacker.party.players), (foe) ->
      foe.emit "combat.enemy.#{attackerEvent}", attacker, defender, extra
    attacker.emit "combat.self.#{attackerEvent}", defender, extra

    _.each (_.without defender.party.players, defender), (partyMate) ->
      partyMate.emit "combat.ally.#{defenderEvent}", defender, attacker, extra

    _.each (_.intersection @turnOrder, defender.party.players), (foe) ->
      foe.emit "combat.enemy.#{defenderEvent}", attacker, defender, extra
    defender.emit "combat.self.#{defenderEvent}", attacker, extra

module.exports = exports = Battle
