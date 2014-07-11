
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
      stat: (stat) =>
        _.reduce @equipment, ((prev, item) -> prev+item[stat]), 0

      stats: (stats) =>
        _.reduce stats, ((prev, stat) => prev+@calc.stat stat), 0

      dodge: ->
        baseValue = @self.calc.stat.apply @self, ['agi']
        @self.personalityReduce 'dodge', [@self, baseValue], baseValue

      beatDodge: ->
        baseValue = Math.max 10, @self.calc.stats.apply @self, [['dex','str','agi','wis','con', 'int']]
        @self.personalityReduce 'beatDodge', [@self, baseValue], baseValue

      hit: ->
        baseValue = (@self.calc.stats.apply @self, [['dex', 'agi', 'con']]) / 6
        @self.personalityReduce 'hit', [@self, baseValue], baseValue

      beatHit: ->
        baseValue = Math.max 10, @self.calc.stats.apply @self, [['str', 'dex']]
        @self.personalityReduce 'beatHit', [@self, baseValue], baseValue

      damage: ->
        baseValue = Math.max 10, @self.calc.stats.apply @self, [['str']]
        @self.personalityReduce 'damage', [@self, baseValue], baseValue

      physicalAttackChance: ->
        baseValue = 100
        @self.personalityReduce 'physicalAttackChance', [@self, baseValue], baseValue

      hp: ->
        baseValue = 0
        @self.personalityReduce 'hp', [@self, baseValue], baseValue

      mp: ->
        baseValue = 0
        @self.personalityReduce 'mp', [@self, baseValue], baseValue

      special: ->
        baseValue = 0
        @self.personalityReduce 'special', [@self, baseValue], baseValue

      combatEndXpGain: (oppParty) ->
        baseValue = 0
        @self.personalityReduce 'combatEndXpGain', [@self, oppParty, baseValue], baseValue

      combatEndXpLoss: ->
        baseValue = Math.floor self.xp.maximum / 10
        @self.personalityReduce 'combatEndXpLoss', [@self, baseValue], baseValue

module.exports = exports = Character