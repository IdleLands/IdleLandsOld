
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

  calcEleBonus: -> @elementalBonus

  prepareCast: ->
    targets = @determineTargets()
    @affect targets

  determineTargets: ->
    do @targetEnemy

  targetFriendlies: (includeDead = no) ->
    _.chain @baseTargets
    .reject (target) ->
      target.hp.atMin() and not includeDead
    .reject (target) =>
      @caster.party isnt target.party
    .value()

  targetFriendly: (includeDead = no, num = 1) ->
    _.sample (@targetFriendlies includeDead), num

  targetEnemies: (includeDead = no) ->
    _.chain @baseTargets
    .reject (target) ->
      target.hp.atMin() and not includeDead
    .reject (target) =>
      @caster.party is target.party
    .value()

  targetEnemy: (includeDead = no, num = 1)->
    _.sample (@targetEnemies includeDead), num

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
          player?.spellsAffectedBy.push @ # got an error here once
          battleInstance.emitEvents "skill.duration.begin", "skill.duration.beginAt", @caster, player, skill: @, turns: @turns

          eventList = _.keys _.omit @bindings, 'doSpellCast', 'doSpellUncast'
          #this would normalize turns / event, but eh, not necessary atm?
          #@turns *= eventList.length
          me = @
          @modifiedBindings = {}
          _.each eventList, (event) =>
            return if @modifiedBindings[event]
            newFunc = ->
              me.bindings[event].apply me, arguments
              me.decrementTurns player

            @modifiedBindings[event] = newFunc
            player.on event, newFunc

        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings

  decrementTurns: (player) ->
    if @turns-- <= 0
      @unaffect player

  unaffect: (player) ->
    battleInstance = @caster.party?.currentBattle
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @
    (@bindings.doSpellUncast.apply @, [player]) if 'doSpellUncast' of @bindings
    _.each (_.keys @modifiedBindings), (event) =>
      player.removeListener event, @modifiedBindings[event]

    return if not battleInstance
    battleInstance.emitEvents "skill.duration.end", "skill.duration.endAt", @caster, player, skill: @

  broadcastBuffMessage: (message) ->
    @game.broadcast MessageCreator.genericMessage message+" [#{@turns} turns]" if @turns > 0

  broadcast: (message) ->
    @game.broadcast MessageCreator.genericMessage message

  constructor: (@game, @caster) ->
    @baseTargets = @caster.party.currentBattle.turnOrder
    @caster[@stat][@oper] @cost
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

  energy: 32
  heal: 64
  buff: 128
  debuff: 256

  normal: 512

Spell::determineType = ->
  if @element & @Element.normal then "physical" else "magical"

module.exports = exports = Spell