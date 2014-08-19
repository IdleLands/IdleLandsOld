
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class Spell
  name: "THIS SPELL HAS NO NAME"
  @restrictions = {}
  stat: @stat = "mp"
  oper: @oper = "sub"
  cost: @cost = 0
  stack: "duration"
  bindings:
    doSpellCast: ->
    doSpellUncast: ->

  bonusElementRanking: 0

  bonusElement: 0 #Spell::Element.none

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
    @caster.party.currentBattle.takeHp @caster, player, damage, @determineType(), @, message

  prepareCast: ->
    targets = @determineTargets()
    @affect targets

  determineTargets: ->
    do @targetEnemy

  targetAll: (includeDead = no, onlyDead = no) ->
    _.chain @baseTargets
    .reject (target) ->
      target.fled
    .reject (target) ->
      target.hp.atMin() and (not includeDead or onlyDead)
    .value()

  targetAny: (includeDead = no, num = 1, onlyDead = no) ->
    _.sample (@targetAll includeDead, onlyDead), num

  targetFriendlies: (includeDead = no, onlyDead = no) ->
    _.chain @baseTargets
    .reject (target) ->
      target.fled
    .reject (target) ->
      target.hp.atMin() and (not includeDead or onlyDead)
    .reject (target) =>
      @caster.party isnt target.party
    .value()

  targetFriendly: (includeDead = no, num = 1, onlyDead = no) ->
    _.sample (@targetFriendlies includeDead, onlyDead), num

  targetEnemies: (includeDead = no, onlyDead = no) ->
    _.chain @baseTargets
    .reject (target) ->
      target.fled
    .reject (target) ->
      target.hp.atMin() and (not includeDead or onlyDead)
    .reject (target) =>
      @caster.party is target.party
    .value()

  targetEnemy: (includeDead = no, num = 1, onlyDead = no) ->
    _.sample (@targetEnemies includeDead, onlyDead), num

  affect: (affected = []) ->
    @affected = if affected and not _.isArray affected then [affected] else affected
    battleInstance = @caster.party.currentBattle
    _.each @affected, (player) =>
      @baseTurns = @turns = turns = @calcDuration player
      battleInstance.emitEvents "skill.use", "skill.used", @caster, player, skill: @
      battleInstance.emitEvents "skill.#{@determineType()}.use", "skill.#{@determineType()}.used", @caster, player, skill: @
      if turns is 0
        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings
      else
        oldSpell = _.findWhere player.spellsAffectedBy, name: @name
        if oldSpell and @stack is "duration"
          oldSpell.turns = oldSpell.calcDuration player
          battleInstance.emitEvents "skill.duration.refresh", "skill.duration.refreshed", @caster, player, skill: oldSpell, turns: oldSpell.turns

        else
          player?.spellsAffectedBy = [] if not player?.spellsAffectedBy
          player?.spellsAffectedBy.push @ # got an error here once
          battleInstance.emitEvents "skill.duration.begin", "skill.duration.beginAt", @caster, player, skill: @, turns: @turns

          eventList = _.keys _.omit @bindings, 'doSpellCast', 'doSpellUncast'
          #this would normalize turns / event, but eh, not necessary atm?
          #@turns *= eventList.length
          me = @
          _.each eventList, (event) =>
            newFunc = ->
              me.bindings[event].apply me, arguments
              me.decrementTurns player

            player.many event, turns, newFunc

        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings

  decrementTurns: (player) ->
    if --@turns <= 0
      @unaffect player

  unaffect: (player) ->
    battleInstance = @caster.party?.currentBattle
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @
    (@bindings.doSpellUncast.apply @, [player]) if 'doSpellUncast' of @bindings

    return if not battleInstance
    battleInstance.emitEvents "skill.duration.end", "skill.duration.endAt", @caster, player, skill: @

  broadcastBuffMessage: (message) ->
    newMessage = MessageCreator.doStringReplace message, @caster
    @game.broadcast MessageCreator.genericMessage newMessage+" [#{@turns} turns]" if (@turns > 0 and @turns isnt @baseTurns) and (not @suppressed)

  broadcast: (message) ->
    newMessage = MessageCreator.doStringReplace message, @caster
    @game.broadcast MessageCreator.genericMessage newMessage if not @suppressed

  constructor: (@game, @caster) ->
    @baseTargets = @caster.party.currentBattle.turnOrder

    @cost = @cost.bind null, @caster if _.isFunction @cost
    @caster[@stat][@oper] _.result @, 'cost'
    @chance = new (require "chance")()

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