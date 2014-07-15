
_ = require "underscore"

class Spell
  name: "THIS SPELL HAS NO NAME"
  @restrictions = {}
  @stat = "mp"
  @cost = 0
  bindings: doSpellCast: ->

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
    _.each @affected, (player) =>
      turns = @calcDuration player
      if turns is 0 then @bindings.doSpellCast.apply @, [player]
      else
        player.spellsAffectedBy.push @

        eventList = _.keys _.omit @bindings, 'doSpellCast'
        @turns *= eventList.length
        _.each eventList, (event) =>
          me = @
          newFunc = ->
            me.decrementTurns player
            me.bindings[event].apply me, [arguments...] #wat
          player.on event, newFunc

        (@bindings.doSpellCast.apply @, [player]) if 'doSpellCast' of @bindings

  decrementTurns: (player) ->
    if @turns-- <= 0
      @unaffect player

  unaffect: (player) ->
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @
    _.each (_.keys @bindings), (event) =>
      player.removeListener event, @bindings[event]

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