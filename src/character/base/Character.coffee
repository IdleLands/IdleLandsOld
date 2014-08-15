
RestrictedNumber = require "restricted-number"
EventEmitter2 = require("eventemitter2").EventEmitter2
_ = require "underscore"
Personality = require "./Personality"
Constants = require "../../system/Constants"

class Character extends EventEmitter2

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

  clearAffectingSpells: ->
    return if not @spellsAffectedBy

    _.each @spellsAffectedBy, (spell) =>
      spell.suppressed = yes
      spell.unaffect @

    @spellsAffectedBy = []

  personalityReduce: (appFunctionName, args = [], baseValue = 0) ->
    args = [args] if not _.isArray args
    array = []
    .concat @profession ? []
    .concat @personalities ? []
    .concat @spellsAffectedBy ? []

    _.reduce array, (combined, iter) ->
      applied = iter?[appFunctionName]?.apply iter, args
      if _.isArray combined
        combined.push applied if applied
      else
        combined += if applied then applied else 0

      combined
    , baseValue

  rebuildPersonalityList: ->
    _.each @personalities, (personality) =>
      personality.unbind @

    @personalities = _.map @personalityStrings, (personality) =>
      Personality::createPersonality personality, @

  addPersonality: (newPersonality) ->
    return no if not Personality::doesPersonalityExist newPersonality

    potentialPersonality = Personality::getPersonality newPersonality
    return no if not ('canUse' of potentialPersonality) or not potentialPersonality.canUse @

    if not @personalityStrings
      @personalityStrings = []
      @personalities = []

    @personalityStrings.push newPersonality

    @personalities.push new potentialPersonality @

    @personalities = _.uniq @personalities
    @personalityStrings = _.uniq @personalityStrings
    yes

  removePersonality: (oldPersonality) ->
    @personalityStrings = _.without @personalityStrings, oldPersonality
    @rebuildPersonalityList()
    yes

  calcGoldGain: (gold) ->
    @calc.stat 'gold', yes, gold

  calcXpGain: (xp) ->
    @calc.stat 'xp', yes, xp

  loadCalc: ->
    @calc =
      base: {}
      self: @
      stat: (stat, ignoreNegative = yes, base = 0, basePct = 0) ->
        pct = "#{stat}Percent"
        @base[stat] = _.reduce @self.equipment, ((prev, item) -> prev+(item[stat] or 0)), base
        @base[pct] = _.reduce @self.equipment, ((prev, item) -> prev+(item[pct] or 0)), basePct

        baseVal = @self.personalityReduce stat, [@self, @base[stat]], @base[stat]
        percent = @self.personalityReduce pct, [@self, @base[pct]], @base[pct]

        newValue = Math.floor baseVal/percent
        newValue = if _.isFinite newValue then newValue else 0

        newValue = 0 if not ignoreNegative and newValue < 0

        combinedVal = baseVal+newValue
        combinedVal = 0 if _.isNaN combinedVal
        combinedVal

      stats: (stats) ->
        _.reduce stats, ((prev, stat) => prev+@stat stat), 0

      dodge: ->
        @base.dodge = @self.calc.stat 'agi'
        @self.personalityReduce 'dodge', [@self, @base.dodge], @base.dodge

      beatDodge: ->
        @base.beatDodge = Math.max 10, @self.calc.stats ['dex','str','agi','wis','con','int']
        @self.personalityReduce 'beatDodge', [@self, @base.beatDodge], @base.beatDodge

      hit: ->
        @base.hit = (@self.calc.stats ['dex', 'agi', 'con']) / 6
        @self.personalityReduce 'hit', [@self, @base.hit], @base.hit

      beatHit: ->
        @base.beatHit = Math.max 10, (@self.calc.stats ['str', 'dex']) / 2
        @self.personalityReduce 'beatHit', [@self, @base.beatHit], @base.beatHit

      damage: ->
        @base.damage = Math.max 10, @self.calc.stats ['str']
        @self.personalityReduce 'damage', [@self, @base.damage], @base.damage

      minDamage: ->
        @base.minDamage = 1
        @self.personalityReduce 'minDamage', [@self, @base.minDamage], @base.minDamage

      physicalAttackChance: ->
        @base.physicalAttackChance = 65
        Math.max 0, Math.min 100, @self.personalityReduce 'physicalAttackChance', [@self, @base.physicalAttackChance], @base.physicalAttackChance

      hp: ->
        @base.hp = 0
        Math.max 1, @self.personalityReduce 'hp', [@self, @base.hp], @base.hp

      mp: ->
        @base.mp = 0
        Math.max 0, @self.personalityReduce 'mp', [@self, @base.mp], @base.mp

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
        Math.floor @self.personalityReduce 'itemScore', [@self, item, baseValue], baseValue

      totalItemScore: ->
        _.reduce @self.equipment, ((prev, item) => prev+item.score()), 0

      itemReplaceChancePercent: ->
        @base.itemReplaceChancePercent = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'itemReplaceChancePercent', [@self, @base.itemReplaceChancePercent], @base.itemReplaceChancePercent

      eventFumble: ->
        @base.eventFumble = 25
        @self.personalityReduce 'eventFumble', [@self, @base.eventFumble], @base.eventFumble

      skillCrit: (spell) ->
        @base.skillCrit = 1
        @self.personalityReduce 'skillCrit', [@self, spell, @base.skillCrit], @base.skillCrit
        
      itemSellMultiplier: (item) ->
        @base.itemSellMultiplier = 0.05
        @self.personalityReduce 'itemSellMultiplier', [@self, item, @base.itemSellMultiplier], @base.itemSellMultiplier

      damageTaken: (attacker, damage, skillType, reductionType) ->
        baseValue = 0
        @self.personalityReduce 'damageTaken', [@self, attacker, damage, skillType, reductionType], baseValue

      cantAct: ->
        baseValue = 0
        @self.personalityReduce 'cantAct', [@self, baseValue], baseValue

      cantActMessages: ->
        baseValue = []
        @self.personalityReduce 'cantActMessages', [@self, baseValue], baseValue

      fleePercent: ->
        @base.fleePercent = 0.1
        @self.personalityReduce 'fleePercent', [@self, @base.fleePercent], @base.fleePercent

      criticalChance: ->
        @base.criticalChance = 1 + @self.calc.stat 'luck'
        @self.personalityReduce 'criticalChance', [@self, @base.criticalChance], @base.criticalChance

      partyLeavePercent: ->
        @base.partyLeavePercent = Constants.defaults.player.defaultPartyLeavePercent
        @self.personalityReduce 'partyLeavePercent', [@self, @base.partyLeavePercent], @base.partyLeavePercent

      classChangePercent: (potential) ->
        @base.classChangePercent = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'classChangePercent', [@self, potential, @base.classChangePercent], @base.classChangePercent

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
