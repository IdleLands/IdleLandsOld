
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
    @createDate = new Date()
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

  canEquip: (item) ->
    current = _.findWhere @equipment, {type: item.type}
    current.score() <= item.score()

  equip: (item) ->
    current = _.findWhere @equipment, {type: item.type}
    @equipment = _.without @equipment, current
    @equipment.push item

  recalculateStats: ->
    @hp.maximum = @calc.hp()
    @mp.maximum = @calc.mp()

  levelUpXpCalc: (level) ->
    Math.floor 100 + (400 * Math.pow level, 1.71)

  gainXp: ->
  gainGold: ->

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

      crit:     -> @self.calc.stat 'crit'
      dance:    -> 0 < @self.calc.stat 'dance'
      defense:  -> @self.calc.stat 'defense'
      prone:    -> 0 < @self.calc.stat 'prone'
      power:    -> 0 < @self.calc.stat 'power'
      offense:  -> @self.calc.stat 'offense'
      glowing:  -> @self.calc.stat 'glowing'
      deadeye:  -> @self.calc.stat 'deadeye'
      silver:   -> 0 < @self.calc.stat 'silver'
      vorpal:   -> 0 < @self.calc.stat 'vorpal'

      boosts: (stats, baseValue) ->
        Math.floor _.reduce stats, (prev, stat) =>
          switch stat
            when 'crit' then                return prev += 100 * @self.calc.crit()
            when 'dance', 'deadeye' then    return prev += baseValue if @self.calc.dance()
            when 'silver', 'power' then     return prev += baseValue / 10 if @self.calc[stat]()
            when 'offense', 'defense' then  return prev += baseValue * @self.calc[stat]()/10
            when 'glowing' then             return prev += baseValue * @self.calc.glowing()/20
            when 'vorpal' then              return prev += baseValue / 2 if @self.calc.vorpal()
          prev
        , 0

      hp: ->
        @base.hp = @self.calc.stat 'hp'
        Math.max 1, @base.hp

      mp: ->
        @base.mp = @self.calc.stat 'mp'
        Math.max 0, @base.mp

      dodge: ->
        @base.dodge = @self.calc.stat 'agi'
        value = @self.personalityReduce 'dodge', [@self, @base.dodge], @base.dodge
        value += @self.calc.boosts ['dance', 'glowing', 'defense'], @base.dodge
        value

      beatDodge: ->
        @base.beatDodge = Math.max 10, @self.calc.stats ['dex','str','agi','wis','con','int']
        value = @self.personalityReduce 'beatDodge', [@self, @base.beatDodge], @base.beatDodge
        value += @self.calc.boosts ['deadeye', 'glowing', 'offense'], @base.beatDodge
        value

      hit: ->
        @base.hit = (@self.calc.stats ['dex', 'agi', 'con']) / 6
        value = @self.personalityReduce 'hit', [@self, @base.hit], @base.hit
        value += @self.calc.boosts ['defense', 'glowing'], @base.hit
        value

      beatHit: ->
        @base.beatHit = Math.max 10, (@self.calc.stats ['str', 'dex']) / 2
        value = @self.personalityReduce 'beatHit', [@self, @base.beatHit], @base.beatHit
        value += @self.calc.boosts ['offense', 'glowing'], @base.beatHit
        value

      damage: ->
        @base.damage = Math.max 10, @self.calc.stats ['str']
        value = @self.personalityReduce 'damage', [@self, @base.damage], @base.damage
        value += @self.calc.boosts ['power', 'offense', 'glowing', 'vorpal'], @base.damage
        value

      minDamage: ->
        @base.minDamage = 1
        maxDamage = @self.calc.damage()
        value = @self.personalityReduce 'minDamage', [@self, @base.minDamage], @base.minDamage
        value += @self.calc.boosts ['silver', 'offense', 'glowing', 'vorpal'], maxDamage
        Math.min value, maxDamage-1

      criticalChance: ->
        @base.criticalChance = 1 + ((@self.calc.stats ['luck', 'dex']) / 2)
        value = @self.personalityReduce 'criticalChance', [@self, @base.criticalChance], @base.criticalChance
        value += @self.calc.boosts ['crit'], @base.criticalChance
        value

      physicalAttackChance: ->
        @base.physicalAttackChance = 65
        Math.max 0, Math.min 100, @self.personalityReduce 'physicalAttackChance', [@self, @base.physicalAttackChance], @base.physicalAttackChance

      combatEndXpGain: (oppParty) ->
        @base.combatEndXpGain = 0
        @self.personalityReduce 'combatEndXpGain', [@self, oppParty, @base.combatEndXpGain], @base.combatEndXpGain

      combatEndXpLoss: ->
        @base.combatEndXpLoss = Math.floor self.xp.maximum / 10
        @self.personalityReduce 'combatEndXpLoss', [@self, @base.combatEndXpLoss], @base.combatEndXpLoss

      itemFindRange: ->
        @base.itemFindRange = (@self.level.getValue()+1) * @self.calc.itemFindRangeMultiplier()
        @self.personalityReduce 'itemFindRange', [@self, @base.itemFindRange], @base.itemFindRange

      itemFindRangeMultiplier: ->
        @base.itemFindRangeMultiplier = Constants.defaults.player.defaultItemFindModifier
        @self.personalityReduce 'itemFindRangeMultipler', [@self, @base.itemFindRangeMultiplier], @base.itemFindRangeMultiplier

      itemScore: (item) ->
        baseValue = item.score()
        Math.floor @self.personalityReduce 'itemScore', [@self, item, baseValue], baseValue

      totalItemScore: ->
        _.reduce @self.equipment, ((prev, item) -> prev+item.score()), 0

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

      damageTaken: (attacker, damage, skillType, spell, reductionType) ->
        baseValue = 0
        @self.personalityReduce 'damageTaken', [@self, attacker, damage, skillType, spell, reductionType], baseValue

      cantAct: ->
        baseValue = 0
        @self.personalityReduce 'cantAct', [@self, baseValue], baseValue

      cantActMessages: ->
        baseValue = []
        @self.personalityReduce 'cantActMessages', [@self, baseValue], baseValue

      fleePercent: ->
        @base.fleePercent = 0.1
        Math.max 0, Math.min 100, @self.personalityReduce 'fleePercent', [@self, @base.fleePercent], @base.fleePercent

      partyLeavePercent: ->
        @base.partyLeavePercent = Constants.defaults.player.defaultPartyLeavePercent
        Math.max 0, Math.min 100, @self.personalityReduce 'partyLeavePercent', [@self, @base.partyLeavePercent], @base.partyLeavePercent

      classChangePercent: (potential) ->
        @base.classChangePercent = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'classChangePercent', [@self, potential, @base.classChangePercent], @base.classChangePercent

      alignment: ->
        @base.alignment = 0
        Math.max -10, Math.min 10, @self.personalityReduce 'alignment', [@self, @base.alignment], @base.alignment

Character::num2dir = (dir,x,y) ->
  switch dir
    when 1 then return {x: x-1, y: y-1}
    when 2 then return {x: x, y: y-1}
    when 3 then return {x: x+1, y: y-1}
    when 4 then return {x: x+1, y: y}
    when 5 then return {x: x+1, y: y+1}
    when 6 then return {x: x, y: y+1}
    when 7 then return {x: x-1, y: y+1}
    when 8 then return {x: x-1, y: y}

    else return {x: x, y: y}

module.exports = exports = Character
