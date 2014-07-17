
_ = require "underscore"

class Spell
  name: "THIS SPELL HAS NO NAME"
  @restrictions = {}
  @stat = "mp"
  @cost = 0
  stack: "duration"
  bindings: doSpellCast: ->
  modifiedBindings: {}

  calcDuration: (player) -> 0

  prepareCast: ->
    targets = @determineTargets()
    @affect targets

  determineTargets: ->
    @targetEnemy()

  targetFriendly: (includeDead = no) ->
    _.sample _.reject @baseTargets, ((target) => ((@caster.party isnt target.party) or (target.hp.atMin() and includeDead)))

  targetEnemy: (includeDead = no)->
    _.sample _.reject @baseTargets, ((target) => ((@caster.party is target.party) or (target.hp.atMin() and includeDead)))

  affect: (affected = []) ->
    @affected = [affected] if affected and not _.isArray affected
    battleInstance = @caster.party.currentBattle
    _.each @affected, (player) =>
      turns = @calcDuration player
      battleInstance.emitEvents "skill.use", "skill.used", @caster, player, skill: @
      battleInstance.emitEvents "skill.#{@determineType()}.use", "skill.#{@determineType()}.used", @caster, player, skill: @
      if turns is 0 then @bindings.doSpellCast.apply @, [player]
      else
        oldSpell = _.findWhere player.spellsAffectedBy, name: @name
        if oldSpell and @stack is "duration"
          oldSpell.turns = oldSpell.calcDuration player
          battleInstance.emitEvents "skill.duration.refresh", "skill.duration.refreshed", @caster, player, skill: oldSpell, turns: oldSpell.turns

        else
          player.spellsAffectedBy.push @
          @turns = @calcDuration player
          battleInstance.emitEvents "skill.duration.begin", "skill.duration.beginAt", @caster, player, skill: @, turns: @turns

          eventList = _.keys _.omit @bindings, 'doSpellCast'
          #this would normalize turns / event, but eh, not necessary atm?
          #@turns *= eventList.length
          me = @
          _.each eventList, (event) =>
            return if @modifiedBindings[event]
            newFunc = ->
              me.bindings[event].apply me, [arguments...] #wat
              me.decrementTurns player

            @modifiedBindings[event] = newFunc
            player.on event, newFunc

        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings

  decrementTurns: (player) ->
    if @turns-- <= 0
      @unaffect player

  unaffect: (player) ->
    battleInstance = @caster.party.currentBattle
    battleInstance.emitEvents "skill.duration.end", "skill.duration.endAt", @caster, player, skill: @
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @
    _.each (_.keys @modifiedBindings), (event) =>
      player.removeListener event, @modifiedBindings[event]

  constructor: (@game, @caster) ->
    @baseTargets = @caster.party.currentBattle.turnOrder
    @caster.mp.sub @cost

Spell::Element =
  # circ-shift these left to get strengths, and right to get weaknesses (truncated @ 16)
  ice: 1
  fire: 2
  water: 4
  thunder: 8
  earth: 16

  energy: 32
  heal: 64
  buff: 128

  normal: 256

Spell::determineType = ->
  if @element & @Element.normal then "physical" else "magical"

module.exports = exports = Spell