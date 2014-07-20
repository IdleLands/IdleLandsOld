
RestrictedNumber = require "restricted-number"
{EventEmitter} = require 'events'
_ = require "underscore"
Personality = require "./Personality"
Constants = require "../../system/Constants"

class Character extends EventEmitter

  constructor: (options) ->
    [@name, @identifier] = [options.name, options.identifier]
    @hp = new RestrictedNumber 0, 20, 20
    @mp = new RestrictedNumber 0, 0, 0
    @special = new RestrictedNumber 0, 0, 0
    @level = new RestrictedNumber 0, 100, 0
    @equipment = []
    @loadCalc()

    @

  moveAction: ->

  combatAction: ->

  personalityReduce: (appFunctionName, args = [], baseValue = 0) ->
    args = [args] if not _.isArray args
    array = []
    .concat @profession ? []
    .concat @personalities ? []
    .concat @spellsAffectedBy ? []

    _.reduce array, (combined, iter) ->
      applied = iter?[appFunctionName]?.apply iter, args
      combined + if applied then applied else 0
    , baseValue

  rebuildPersonalityList: ->
    @personalities = _.map @personalityStrings, (personality) ->
      Personality::createPersonality personality

  addPersonality: (newPersonality) ->
    return no if not Personality::doesPersonalityExist newPersonality

    if not @personalityStrings
      @personalityStrings = []
      @personalities = []

    @personalityStrings.push newPersonality

    @personalities.push Personality::createPersonality newPersonality

    @personalities = _.uniq @personalities
    yes

  removePersonality: (oldPersonality) ->
    @personalityStrings = _.without @personalityStrings, oldPersonality
    @rebuildPersonalityList()
    yes

  loadCalc: ->
    @calc =
      base: {}
      self: @
      stat: (stat) ->
        @base[stat] = _.reduce @self.equipment, ((prev, item) -> prev+item[stat]), 0
        @self.personalityReduce stat, [@self, @base[stat]], @base[stat]

      stats: (stats) ->
        _.reduce stats, ((prev, stat) => prev+@stat stat), 0

      dodge: ->
        @base.dodge = @self.calc.stat ['agi']
        @self.personalityReduce 'dodge', [@self, @base.dodge], @base.dodge

      beatDodge: ->
        @base.beatDodge = Math.max 10, @self.calc.stats [['dex','str','agi','wis','con', 'int']]
        @self.personalityReduce 'beatDodge', [@self, @base.beatDodge], @base.beatDodge

      hit: ->
        @base.hit = (@self.calc.stats [['dex', 'agi', 'con']]) / 6
        @self.personalityReduce 'hit', [@self, @base.hit], @base.hit

      beatHit: ->
        @base.beatHit = Math.max 10, @self.calc.stats [['str', 'dex']]
        @self.personalityReduce 'beatHit', [@self, @base.beatHit], @base.beatHit

      damage: ->
        @base.damage = Math.max 10, @self.calc.stats [['str']]
        @self.personalityReduce 'damage', [@self, @base.damage], @base.damage

      physicalAttackChance: ->
        @base.physicalAttackChance = 75
        @self.personalityReduce 'physicalAttackChance', [@self, @base.physicalAttackChance], @base.physicalAttackChance

      hp: ->
        @base.hp = 0
        @self.personalityReduce 'hp', [@self, @base.hp], @base.hp

      mp: ->
        @base.mp = 0
        @self.personalityReduce 'mp', [@self, @base.mp], @base.mp

      special: ->
        @base.special = 0
        @self.personalityReduce 'special', [@self, @base.special], @base.special

      combatEndXpGain: (oppParty) ->
        @base.combatEndXpGain = 0
        @self.personalityReduce 'combatEndXpGain', [@self, oppParty, @base.combatEndXpGain], @base.combatEndXpGain

      combatEndXpLoss: ->
        @base.combatEndXpLoss = Math.floor self.xp.maximum / 10
        @self.personalityReduce 'combatEndXpLoss', [@self, @base.combatEndXpLoss], @base.combatEndXpLoss

      itemFindRangeMultiplier: ->
        @base.itemFindRangeMultiplier = Constants.defaults.player.defaultItemFindModifier
        @self.personalityReduce 'itemFindRangeMultipler', [@self, @base.itemFindRangeMultiplier], @base.itemFindRangeMultiplier

      itemScore: (item) ->
        baseValue = item.score()
        @self.personalityReduce 'itemScore', [@self, item, baseValue], baseValue

      eventFumble: (item) ->
        @base.eventFumble = 25
        @self.personalityReduce 'eventFumble', [@self, item, @base.eventFumble], @base.eventFumble

Character::num2dir = (dir,x,y) ->
  switch dir
    when 1 then return {x: x-1, y: y-1}
    when 2 then return {x: x, y: y-1}
    when 3 then return {x: x+1, y: y-1}
    when 4 then return {x: x-1, y: y}

    when 6 then return {x: x+1, y: y}
    when 7 then return {x: x-1, y: y+1}
    when 8 then return {x: x, y: y+1}
    when 9 then return {x: x+1, y: y+1}

    else return {x: x, y: y}

module.exports = exports = Character