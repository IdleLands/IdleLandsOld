
RestrictedNumber = require "restricted-number"
{EventEmitter} = require 'events'
_ = require "underscore"
Personality = require "./Personality"

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

  num2dir: (dir,x,y) ->
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

  moveAction: ->

  combatAction: ->

  personalityReduce: (appFunctionName, args = [], baseValue = 0) ->
    args = [args] if not _.isArray args
    array = []
    .concat @profession ? []
    .concat @personalities ? []

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
      self: @
      base: {}
      stat: (stat) =>
        _.reduce @equipment, ((prev, item) -> prev+item[stat]), 0

      stats: (stats) =>
        _.reduce stats, ((prev, stat) => prev+@calc.stat stat), 0

      dodge: ->
        @base.dodge = @self.calc.stat.apply @self, ['agi']
        @self.personalityReduce 'dodge', [@self, @base.dodge], @base.dodge

      beatDodge: ->
        @base.beatDodge = Math.max 10, @self.calc.stats.apply @self, [['dex','str','agi','wis','con', 'int']]
        @self.personalityReduce 'beatDodge', [@self, @base.beatDodge], @base.beatDodge

      hit: ->
        @base.hit = (@self.calc.stats.apply @self, [['dex', 'agi', 'con']]) / 6
        @self.personalityReduce 'hit', [@self, @base.hit], @base.hit

      beatHit: ->
        @base.beatHit = Math.max 10, @self.calc.stats.apply @self, [['str', 'dex']]
        @self.personalityReduce 'beatHit', [@self, @base.beatHit], @base.beatHit

      damage: ->
        @base.damage = Math.max 10, @self.calc.stats.apply @self, [['str']]
        @self.personalityReduce 'damage', [@self, @base.damage], @base.damage

      physicalAttackChance: ->
        @base.physicalAttackChance = 100
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

module.exports = exports = Character