
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class Spell
  name: "THIS SPELL HAS NO NAME"
  @restrictions = {}
  @canChoose = (caster) -> yes
  stat: @stat = "mp"
  oper: @oper = "sub"
  cost: @cost = 0
  tiers: @tiers = []
  spellPower: @spellPower = 1
  stack: "duration"
  bindings:
    doSpellCast: ->
    doSpellUncast: ->

  bonusElementRanking: 0
  bonusElement: 0 #Spell::Element.none

  ## utility chooser functions
  gpmbmh = @getPartyMembersBelowMaxHealth = (player) ->
    return [] if not player.party
    _.chain player.party.players
      .reject (member) -> member.hp.atMax()
      .value()

  @areAnyPartyMembersBelowMaxHealth = (player) ->
    gpmbmh(player).length > 0

  ## / utility chooser functions

  ## targetting functions
  determineTargets: ->
    return @forcedTargets if @forcedTargets
    @targetSomeEnemies size: 1

  _chooseTargets: (targets, options = {}) ->
    options = _.defaults options, {guaranteeSize: no, size: 1}
    return (_.sample targets, options.size) if not options.guaranteeSize
    ret = []
    ret.push (_.sample targets) while ret.length < options.size
    ret

  _baseTarget: (options = {}) ->
    options = _.defaults options, {includeLiving: yes, includeDead: no}
    _.chain @baseTargets
    .reject (target) -> target.fled
    .filter (target) ->
      return yes if not options.includeDead
      target.hp.atMin()
    .filter (target) ->
      return yes if not options.includeLiving
      not target.hp.atMin()
    .value()

  targetAll: (options) ->
    @_baseTarget options

  targetSome: (options) ->
    @_chooseTargets (@targetAll options), options

  targetAllAllies: (options) ->
    _.reject (@targetAll options), (target) => @caster.party isnt target.party

  targetSomeAllies: (options) ->
    @_chooseTargets (@targetAllAllies options), options

  targetAllEnemies: (options) ->
    _.reject (@targetAll options), (target) => @caster.party is target.party

  targetSomeEnemies: (options) ->
    @_chooseTargets (@targetAllEnemies options), options

  ## specialized targetting functions
  targetBelowMaxHealth: (party) ->
    _.reject party, (member) -> member.hp.atMax()

  targetLowestHp: (party) ->
    _.chain party
      .reject (member) -> member.hp.atMin()
      .min (member) -> member.hp.asPercent()
      .value()

  ## / targetting functions

  calcTier: (player) ->
    return if @tiers.length == 0
    spellTier = _.reject @tiers, (tier) -> (tier.level > player.level.getValue()) or (player.professionName != tier.class)
    spellTier = _.max spellTier, (tier) -> tier.level
    @name = spellTier.name
    @spellPower = spellTier.spellPower
    if _.isFunction spellTier.cost
      @cost = spellTier.cost.bind null, @caster
    else
      @cost = spellTier.cost

  calcDuration: (player) -> @bonusElementRanking

  calcDamage: ->
    damage = 0
    for damageType, damageBit of @Element
      continue if not @element & damageBit
      damage += @caster.calc.stat damageType

    damage

  minMax: (min, max) ->
    @chance.integer min: min, max: Math.max min+1, max

  doDamageTo: (player, damage, message = "") ->
    extra =
      casterName: @caster.name
      targetName: player.name
      spellName: @name

    damage = player.calcDamageTaken damage

    message = MessageCreator.doStringReplace message, @caster, extra

    @caster.party?.currentBattle?.takeHp @caster, player, damage, @determineType(), @, message

  prepareCast: ->
    enemies = @determineTargets()
    enemies = [enemies] if not _.isArray enemies
    targets = @caster.calc.magicalAttackTargets enemies, @baseTargets
    @affect targets

  affect: (@affected = []) ->
    battleInstance = @caster.party.currentBattle

    (@bindings.doSpellInit.apply @, []) if 'doSpellInit' of @bindings

    @baseTurns = {}
    @turns = {}
    turns = {}

    _.each @affected, (player) =>
      if not player
        console.error "INVALID PLAYER for #{@baseName}"
        return

      @baseTurns[player.name] = @turns[player.name] = turns[player.name] = @calcDuration player
      battleInstance.emitEvents "skill.use", "skill.used", @caster, player, skill: @
      battleInstance.emitEvents "skill.#{@determineType()}.use", "skill.#{@determineType()}.used", @caster, player, skill: @
      if turns[player.name] is 0
        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings
      else
        oldSpell = _.findWhere player.spellsAffectedBy, baseName: @baseName
        if oldSpell and @stack is "duration"
          oldSpell.turns[player.name] = oldSpell.calcDuration player
          battleInstance.emitEvents "skill.duration.refresh", "skill.duration.refreshed", @caster, player, skill: oldSpell, turns: oldSpell.turns

        else
          player?.spellsAffectedBy = [] if not player?.spellsAffectedBy
          player?.spellsAffectedBy.push @ # got an error here once
          battleInstance.emitEvents "skill.duration.begin", "skill.duration.beginAt", @caster, player, skill: @, turns: @turns

          @eventList = _.keys _.omit @bindings, 'doSpellCast', 'doSpellUncast', 'doSpellInit'
          me = @
          @eventFunctions = {}
          _.each @eventList, (event) ->
            newFunc = ->
              return if not (me in player.spellsAffectedBy)
              me.bindings[event].apply me, [player]
              me.decrementTurns player

            player.many event, turns[player.name], newFunc

        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings

  decrementTurns: (player) ->
    if --@turns[player.name] <= 0
      @unaffect player

  unaffect: (player) ->
    battleInstance = @caster.party?.currentBattle
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @
    (@bindings.doSpellUncast.apply @, [player]) if 'doSpellUncast' of @bindings

    return if not battleInstance
    battleInstance.emitEvents "skill.duration.end", "skill.duration.endAt", @caster, player, skill: @

  broadcastBuffMessage: (target, message) ->
    extra =
      spellName: @name
      targetName: target.name
      casterName: @caster.name

    newMessage = MessageCreator.doStringReplace message, @caster, extra
    @game.broadcast MessageCreator.genericMessage newMessage+" [<spell.turns>#{@turns[target.name]}</spell.turns> turns]" if (@turns[target.name] > 0 and @turns[target.name] isnt @baseTurns[target.name]) and (not @suppressed)

  broadcast: (target, message) ->
    extra =
      spellName: @name
      targetName: target.name
      casterName: @caster.name

    newMessage = MessageCreator.doStringReplace message, @caster, extra
    @game.broadcast MessageCreator.genericMessage newMessage if not @suppressed and not target.fled

  constructor: (@game, @caster, @forcedTargets = null) ->
    @baseName = @name
    @baseTargets = @caster.party.currentBattle.turnOrder
    @calcTier @caster
    @caster[@stat][@oper] _.result @, 'cost'
    @chance = new (require "chance")()

    premsg = @caster.messages?[@__proto__.constructor.name]
    message = "<#{@caster.name}> #{premsg}"
    @broadcast @caster, message if premsg

    console.error "ERROR NO CASTER FOR #{@name}" if not @caster

Spell::Element =
  none: 0
  # circ-shift these left to get strengths, and right to get weaknesses (truncated @ 16)
  ice: 1
  fire: 2
  water: 4
  thunder: 8
  earth: 16

  holy: 1 | 2 | 4 | 8 | 16

  energy: 32
  heal: 64
  buff: 128
  debuff: 256

  physical: 512

Spell::determineType = ->
  if @element & @Element.physical then "physical" else "magical"

module.exports = exports = Spell