
_ = require "underscore"
MessageCreator = require "../../system/MessageCreator"

class Spell
  name: "THIS SPELL HAS NO NAME"
  @restrictions = {}
  @stat = "mp"
  @cost = 0
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
    _.reject @baseTargets, ((target) => ((@caster.party isnt target.party) or (target.hp.atMin() and includeDead)))

  targetFriendly: (includeDead = no, num = 1) ->
    _.sample (@targetFriendlies includeDead), num

  targetEnemies: (includeDead = no) ->
    _.reject @baseTargets, ((target) => ((@caster.party is target.party) or (target.hp.atMin() and includeDead)))

  targetEnemy: (includeDead = no, num = 1)->
    _.sample (@targetEnemies includeDead), num

  affect: (affected = []) ->
    @affected = if affected and not _.isArray affected then [affected] else affected
    battleInstance = @caster.party.currentBattle
    _.each @affected, (player) =>
      turns = @calcDuration player
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
          @turns = turns
          battleInstance.emitEvents "skill.duration.begin", "skill.duration.beginAt", @caster, player, skill: @, turns: @turns

          eventList = _.keys _.omit @bindings, 'doSpellCast', 'doSpellUncast'
          #this would normalize turns / event, but eh, not necessary atm?
          #@turns *= eventList.length
          me = @
          @modifiedBindings = {}
          _.each eventList, (event) =>
            #console.log "ATTEMPTING TO BIND #{@name} to #{event} - #{@modifiedBindings[event]}"
            return if @modifiedBindings[event]
            #console.log "DEFINITELY TO BIND #{@name} to #{event}"
            newFunc = ->
              #console.log "INNER"
              me.bindings[event].apply me, arguments #wat
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
    @caster.mp.sub @cost

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

  normal: 256

Spell::determineType = ->
  if @element & @Element.normal then "physical" else "magical"

module.exports = exports = Spell