
RestrictedNumber = require "restricted-number"
EventEmitter2 = require("eventemitter2").EventEmitter2
_ = require "lodash"
Q = require "q"
Personality = require "./Personality"
Constants = require "../../system/utilities/Constants"
chance = new (require "chance")()

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
    @setMaxListeners 0

    @

  getName: ->
    if @title then "#{@name}, the #{@title}" else @name

  resetMaxXp: ->
    @xp.maximum = @levelUpXpCalc @level.getValue()

  moveAction: ->

  clearAffectingSpells: ->
    return if not @spellsAffectedBy

    _.each @spellsAffectedBy, (spell) =>
      spell.suppressed = yes
      spell.unaffect @

    @spellsAffectedBy = []

  checkBuffs: ->
    @buffsAffectedBy = _.reject @buffsAffectedBy, ((buff) -> buff.expire < Date.now())

  _getAffectingFactors: ->
    @checkBuffs() if @buffsAffectedBy
    []
    .concat @profession ? []
    .concat @personalities ? []
    .concat @spellsAffectedBy ? []
    .concat @achievements ? []
    .concat @playerManager?.game.calendar.getDateEffects()
    .concat @calendar?.game.calendar.getDateEffects() # for monsters
    .concat @getRegion?()
    .concat @playerManager?.game.guildManager.guildHash[@guild]?.buffs ? []
    .concat @buffsAffectedBy ? []

  probabilityReduce: (appFunctionName, args = [], baseObject) ->
    args = [args] if not _.isArray args
    array = @_getAffectingFactors()

    baseProbabilities = if baseObject then [baseObject] else []

    probabilities = _.reduce array, (combined, iter) ->
      applied = if _.isFunction iter?[appFunctionName] then iter?[appFunctionName]?.apply iter, args else iter?[appFunctionName]
      combined.push applied if applied?.result.length > 0
      combined
    , baseProbabilities

    return probabilities[0] if probabilities.length < 2

    sortedProbabilities = _.sortBy probabilities, (prob) -> prob.probability
    minProbability = sortedProbabilities[0].probability
    sum = _.reduce sortedProbabilities, ((prev, prob) -> prev + prob.probability), 0
    sortedProbabilities[i].probability = sortedProbabilities[i].probability + sortedProbabilities[i-1].probability for i in [1...sortedProbabilities.length]
    chosenInt = chance.integer {min: minProbability, max: sum}
    (_.reject sortedProbabilities, (val) -> val.probability < chosenInt)[0]

  personalityReduce: (appFunctionName, args = [], baseValue = 0) ->
    args = [args] if not _.isArray args
    array = @_getAffectingFactors()

    _.reduce array, (combined, iter) ->
      applied = if _.isFunction iter?[appFunctionName] then iter?[appFunctionName]?.apply iter, args else iter?[appFunctionName]
      if _.isArray combined
        combined.push applied if applied
      else
        combined += if applied then applied else 0

      combined
    , baseValue

  rebuildPersonalityList: ->
    _.each @personalities, (personality) =>
      personality.unbind? @

    @personalities = _.map @personalityStrings, (personality) =>
      Personality::createPersonality personality, @

  _addPersonality: (newPersonality, potentialPersonality) ->
    if not @personalityStrings
      @personalityStrings = []
      @personalities = []

    @personalityStrings.push newPersonality

    @personalities.push new potentialPersonality @

    @personalities = _.uniq @personalities
    @personalityStrings = _.uniq @personalityStrings

  addPersonality: (newPersonality) ->
    if not Personality::doesPersonalityExist newPersonality
      return Q {isSuccess: no, code: 30, message: "That personality doesn't exist (they're case sensitive)!"}

    potentialPersonality = Personality::getPersonality newPersonality
    if not ('canUse' of potentialPersonality) or not potentialPersonality.canUse @
      return Q {isSuccess: no, code: 31, message: "You can't use that personality yet!"}

    @_addPersonality newPersonality, potentialPersonality

    personalityString = @personalityStrings.join ", "

    Q {isSuccess: yes, code: 33, message: "Your personality settings have been updated successfully! Personalities are now: #{personalityString or "none"}"}

  removePersonality: (oldPersonality) ->
    if not @hasPersonality oldPersonality
      return Q {isSuccess: no, code: 32, message: "You don't have that personality set!"}

    @personalityStrings = _.without @personalityStrings, oldPersonality
    @rebuildPersonalityList()

    personalityString = @personalityStrings.join ", "

    Q {isSuccess: yes, code: 33, message: "Your personality settings have been updated successfully! Personalities are now: #{personalityString or "none"}"}

  removeAllPersonalities: ->
    @personalityStrings = []
    @rebuildPersonalityList()

  hasPersonality: (personality) ->
    return no if not @personalityStrings
    personality in @personalityStrings

  calcGoldGain: (gold) ->
    @calc.stat 'gold', yes, gold

  calcXpGain: (xp) ->
    @calc.stat 'xp', yes, xp

  calcDamageTaken: (baseDamage) ->
    multiplier = @calc.damageMultiplier()
    if baseDamage > 0
      damage = (baseDamage - @calc.damageReduction()) * multiplier
      damage = 0 if damage < 0
      damage
    else baseDamage*multiplier

  modifyRelationshipWith: (playerName, value) ->
    @rapport = {} if not @rapport
    @rapport[playerName] = 0 if not @rapport[playerName]

    @rapport[playerName] += value

  canEquip: (item) ->
    return yes if (-1 isnt item.equippedBy.indexOf(if @isPet then @createdAt else @name))

    current = _.findWhere @equipment, {type: item.type}
    current.score() <= item.score()

  equip: (item) ->
    current = _.findWhere @equipment, {type: item.type}
    @equipment = _.without @equipment, current
    @equipment.push item

    @addToEquippedBy item

    return if @isMonster
    @permanentAchievements.hasFoundForsaken = yes if item.forsaken
    @permanentAchievements.hasFoundSacred   = yes if item.sacred

  addToEquippedBy: (item) ->
    item.equippedBy = [] if not item.equippedBy
    item.equippedBy.push if @isPet then @createdAt else @name
    item.equippedBy = _.uniq item.equippedBy

  calculateYesPercent: ->
    Math.min 100, (Math.max 0, Constants.defaults.player.defaultYesPercent + @personalityReduce 'calculateYesPercentBonus')

  recalculateStats: ->

    @calc.itemFindRange()

    # force a recalculation
    @calc.stats ['str', 'dex', 'con', 'int', 'agi', 'luck', 'wis', 'water', 'fire', 'earth', 'ice', 'thunder']

    @hp.maximum = @calc.hp()
    @mp.maximum = @calc.mp()

  levelUpXpCalc: (level) ->
    Math.floor 100 + (400 * Math.pow level, 1.71)

  calcLuckBonusFromValue: (value) ->
    tiers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 25, 35, 50, 65, 75, 85, 100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500]

    postMaxTierDifference = 100

    bonus = 0

    for i in [0..tiers.length]
      bonus++ if value >= tiers[i]

    if value >= tiers[tiers.length-1]
      bonus++ while value > tiers[tiers.length-1] += postMaxTierDifference

    bonus

  gainXp: ->
  gainGold: ->

  loadCalc: ->
    @calc =
      base: {}
      statCache: {}
      self: @
      stat: (stat, ignoreNegative = yes, base = 0, basePct = 0) ->
        pct = "#{stat}Percent"
        @base[stat] = _.reduce @self.equipment, ((prev, item) -> prev+(item[stat] or 0)), base
        @base[pct] = _.reduce @self.equipment, ((prev, item) -> prev+(item[pct] or 0)), basePct

        baseVal = @self.personalityReduce stat, [@self, @base[stat]], @base[stat]
        @statCache[pct] = percent = @self.personalityReduce pct, [@self, @base[pct]], @base[pct]

        combinedVal = Math.round(baseVal*(1+percent/100))
        combinedVal = 0 if _.isNaN combinedVal or (not ignoreNegative and combinedVal < 0)
        @statCache[stat] = combinedVal

        combinedVal

      stats: (stats) ->
        _.reduce stats, ((prev, stat) => prev+@self.calc.stat stat), 0

      #`/**
      # * Absolute adds a static amount of damage to all of your attacks.
      # *
      # * @name absolute
      # * @combat
      # * @stacks yes (Stacking formula is +1 damage/absolute point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      absolute: -> Math.max 0, @self.calc.stat 'absolute'

      #`/**
      # * Aegis prevents critical hits.
      # *
      # * @name aegis
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      aegis: -> 0 < @self.calc.stat 'aegis'

      #`/**
      # * Crit adds a bonus to your critical chance.
      # *
      # * @name crit
      # * @combat
      # * @stacks yes (Stacking formula is 100/crit point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      crit: -> Math.max 0, @self.calc.stat 'crit'

      #`/**
      # * Dance doubles your base dodge chance.
      # *
      # * @name dance
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      dance:    -> 0 < @self.calc.stat 'dance'

      #`/**
      # * Darkside makes it so you do more damage, but all of the bonus damage is taken by both the attacker and defender.
      # *
      # * @name darkside
      # * @combat
      # * @stacks yes (Stacking formula is 10%/darkside point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      darkside:  -> Math.max 0, @self.calc.stat 'darkside'

      #`/**
      # * Deadeye doubles your chance to overcome the opponents dodge roll.
      # *
      # * @name deadeye
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      deadeye:  -> 0 < Math.max 0, @self.calc.stat 'deadeye'

      #`/**
      # * Defense adds a +10% boost to all of your defensive calculations.
      # *
      # * @name defense
      # * @combat
      # * @stacks yes (Stacking formula is 10%/defense point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      defense:  -> Math.max 0, @self.calc.stat 'defense'

      #`/**
      # * Drunk changes your movements ever-so-slightly.
      # *
      # * @name drunk
      # * @stacks yes
      # * @category Equipment Effects
      # * @package Item
      # */`
      drunk:  -> Math.max 0, @self.calc.stat 'drunk'

      #`/**
      # * Fear makes it so no opponents can flee combat. Works well on Jesters!
      # *
      # * @name fear
      # * @combat
      # * @stacks yes
      # * @category Equipment Effects
      # * @package Item
      # */`
      fear:  -> @self.calc.stat 'fear'

      #`/**
      # * Glowing adds +5% to each of your combat calculations. It's pretty crazy.
      # *
      # * @name glowing
      # * @combat
      # * @stacks yes (Stacking formula is 5%/glowing point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      glowing:  -> Math.max 0, @self.calc.stat 'glowing'

      #`/**
      # * Haste allows you to take one additional step per point of haste. You only gain xp for your first 5 steps.
      # *
      # * @name haste
      # * @stacks yes (Stacking formula is +1 step/haste point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      haste:    -> Math.max 0, @self.calc.stat 'haste'

      #`/**
      # * Lethal makes all of your critical hits even more critical, so they deal 150% damage.
      # *
      # * @name lethal
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      lethal:   -> 0 < @self.calc.stat 'lethal'

      #`/**
      # * Mindwipe makes the target forget that they have any personalities.
      # *
      # * @name mindwipe
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      mindwipe:    -> 0 < @self.calc.stat 'mindwipe'

      #`/**
      # * Parry allows you the chance to counterattack if you dodge, deflect, or are missed by an attack.
      # *
      # * @name parry
      # * @combat
      # * @stacks yes (Stacking formula is +10% parry chance/parry point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      parry:    -> @self.calc.stat 'parry'

      #`/**
      # * Poison is a small DoT that does damage based on the attackers wisdom.
      # *
      # * @name poison
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      poison:    -> 0 < @self.calc.stat 'poison'

      #`/**
      # * Power adds a flat +10% to maximum damage possible.
      # *
      # * @name power
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      power:    -> 0 < @self.calc.stat 'power'

      #`/**
      # * Prone gives you the opportunity to stun an opponent when you physically hit them. The chance of a stun happening is 15%.
      # *
      # * @name prone
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      prone:    -> 0 < @self.calc.stat 'prone'

      #`/**
      # * Punish allows you to return some damage back to the attacker.
      # *
      # * @name punish
      # * @combat
      # * @stacks yes (Stacking formula is +5% returned damage/punish point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      punish:    -> Math.max 0, @self.calc.stat 'punish'

      #`/**
      # * Offense adds a +10% boost for each of your offensive calculations.
      # *
      # * @name offense
      # * @combat
      # * @stacks yes (Stacking formula is 10%/offense point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      offense:  -> Math.max 0, @self.calc.stat 'offense'

      #`/**
      # * Royal adds +1% xp gain at the end of combat. It also can go negative, which lowers your xp gain cap at the end of combat!
      # *
      # * @name royal
      # * @combat
      # * @stacks yes (Stacking formula is 1%/royal point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      royal:  -> @self.calc.stat 'royal'

      #`/**
      # * Shatter has a chance to destroy the opponents defenses for a few turns.
      # *
      # * @name shatter
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      shatter:   -> 0 < @self.calc.stat 'shatter'

      #`/**
      # * Silver increases your minimum damage range by +10%.
      # *
      # * @name silver
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      silver:   -> 0 < @self.calc.stat 'silver'

      #`/**
      # * Startle allows you to take away your opponents first turns.
      # *
      # * @name startle
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      startle:  -> @self.calc.stat 'startle'

      #`/**
      # * Sturdy allows you to survive a fatal attack with 1 hp.
      # *
      # * @name sturdy
      # * @requirement {max-hp} 5000
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      sturdy:  -> @self.hp.maximum > 5000 and Math.max 0, @self.calc.stat 'sturdy'

      #`/**
      # * Vampire is a DoT that returns health to the attacker. The duration is determined by how many points of vampire the caster has.
      # *
      # * @name vampire
      # * @combat
      # * @stacks yes (Stacking formula is 1 turn/vampire point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      vampire:    -> Math.max 0, @self.calc.stat 'vampire'

      #`/**
      # * Venom is a small DoT that does a static percentage of the victims health as damage.
      # *
      # * @name venom
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      venom:    -> 0 < @self.calc.stat 'venom'

      #`/**
      # * Vorpal increases your minimum and maximum damage by +50%
      # *
      # * @name vorpal
      # * @combat
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`
      vorpal:   -> 0 < @self.calc.stat 'vorpal'

      #`/**
      # * Forsaken makes it so every blessItem, flipStat, or forsakeItem hits this item. In the event that
      # * there are multiple forsaken items in your inventory, one will be chosen at random.
      # *
      # * @name forsaken
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`

      #`/**
      # * Limitless allows an item to exceed the enchantment level cap of 10.
      # *
      # * @name limitless
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`

      #`/**
      # * Sacred makes it so there is no chance of this item being hit by blessItem, flipStat, or forsakeItem.
      # *
      # * @name sacred
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`

      #`/**
      # * Sentimentality does nothing except take up valuable equipment score.
      # *
      # * @name sentimentality
      # * @stacks no
      # * @category Equipment Effects
      # * @package Item
      # */`

      #`/**
      # * Sticky makes it harder to have your item be replaced (or easier, if you have negative sticky).
      # *
      # * @name sticky
      # * @stacks yes
      # * @category Equipment Effects
      # * @package Item
      # */`

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
        Math.round Math.max 1, @base.hp

      mp: ->
        @base.mp = @self.calc.stat 'mp'
        Math.round Math.max 0, @base.mp

      ##TAG:REDUCTION: dodge | agi | self, baseDodge | Called when attempting to dodge
      dodge: ->
        @base.dodge = @self.calc.stat 'agi'
        value = @self.personalityReduce 'dodge', [@self, @base.dodge], @base.dodge
        value += @self.calc.boosts ['dance', 'glowing', 'defense'], @base.dodge
        value

      ##TAG:REDUCTION: beatDodge | dex+str+agi+wis+con+int | self, baseBeatDodge | Called when attempting to prevent opponent dodging
      beatDodge: ->
        @base.beatDodge = Math.max 10, @self.calc.stats ['dex','str','agi','wis','con','int']
        value = @self.personalityReduce 'beatDodge', [@self, @base.beatDodge], @base.beatDodge
        value += @self.calc.boosts ['deadeye', 'glowing', 'offense'], @base.beatDodge
        value

      ##TAG:REDUCTION: hit | dex+agi+con/6 | self, baseHit | Called when attempting to not get hit
      hit: ->
        @base.hit = (@self.calc.stats ['dex', 'agi', 'con']) / 6
        value = @self.personalityReduce 'hit', [@self, @base.hit], @base.hit
        value += @self.calc.boosts ['defense', 'glowing'], @base.hit
        value

      ##TAG:REDUCTION: beatHit | str+dex/2 | self, baseBeatHit | Called when attempting to hit opponent
      beatHit: ->
        @base.beatHit = Math.max 10, (@self.calc.stats ['str', 'dex']) / 2
        value = @self.personalityReduce 'beatHit', [@self, @base.beatHit], @base.beatHit
        value += @self.calc.boosts ['offense', 'glowing'], @base.beatHit
        value

      ##TAG:REDUCTION: damage | str | self, baseDamage | Called when rolling any kind of damage
      damage: ->
        @base.damage = Math.max 10, @self.calc.stats ['str']
        value = @self.personalityReduce 'damage', [@self, @base.damage], @base.damage
        value += @self.calc.boosts ['power', 'offense', 'glowing', 'vorpal'], @base.damage
        Math.round value

      ##TAG:REDUCTION: minDamage | 1 | self, baseMinDamage | Called when rolling any kind of damage
      minDamage: ->
        @base.minDamage = 1
        maxDamage = @self.calc.damage()
        value = @self.personalityReduce 'minDamage', [@self, @base.minDamage], @base.minDamage
        value += @self.calc.boosts ['silver', 'offense', 'glowing', 'vorpal'], maxDamage
        Math.min value, maxDamage-1

      #`/**
      # * Damage reduction makes it so you take less damage.
      # *
      # * @name damageReduction
      # * @combat
      # * @stacks yes (Stacking formula is -1 damage / damageReduction point)
      # * @category Equipment Effects
      # * @package Item
      # */`
      ##TAG:REDUCTION: damageReduction | 0 | self, baseDamageReduction | Called when calculating damage
      damageReduction: ->
        @base.damageReduction = 0
        @self.personalityReduce 'damageReduction', [@self, @base.damageReduction], @base.damageReduction

      ##TAG:REDUCTION: damageMultiplier | 1 | self, baseDamageMultiplier | Called when calculating damage
      damageMultiplier: ->
        @base.damageMultiplier = 1
        @self.personalityReduce 'damageMultiplier', [@self, @base.damageMultiplier], @base.damageMultiplier

      ##TAG:REDUCTION: criticalChance | 1+luck+dex/2 | self, baseCriticalChance | Called when attempting to do a critical hit, before calculating damage
      criticalChance: ->
        @base.criticalChance = 1 + ((@self.calc.stats ['luck', 'dex']) / 2)
        value = @self.personalityReduce 'criticalChance', [@self, @base.criticalChance], @base.criticalChance
        value += @self.calc.boosts ['crit'], @base.criticalChance
        value

      ##TAG:REDUCTION: physicalAttackChance | 65 | self, basePhysicalAttackChance | Called when determining whether to do a physical or magical attack at the beginning of the turn
      physicalAttackChance: ->
        @base.physicalAttackChance = 65
        Math.max 0, Math.min 100, @self.personalityReduce 'physicalAttackChance', [@self, @base.physicalAttackChance], @base.physicalAttackChance

      ##TAG:REDUCTION: combatEndXpGain | 0 | self, baseCombatEndXpGain | Called when calculating the base xp gain after combat
      combatEndXpGain: (oppParty) ->
        @base.combatEndXpGain = 0
        @self.personalityReduce 'combatEndXpGain', [@self, oppParty, @base.combatEndXpGain], @base.combatEndXpGain

      ##TAG:REDUCTION: combatEndXpLoss | maxXp/10 | self, baseCombatEndXpLoss | Called when calculating the base xp loss after combat
      combatEndXpLoss: ->
        @base.combatEndXpLoss = Math.floor @self.xp.maximum / 10
        @self.personalityReduce 'combatEndXpLoss', [@self, @base.combatEndXpLoss], @base.combatEndXpLoss

      ##TAG:REDUCTION: combatEndGoldGain | 0 | self, baseCombatEndGoldGain | Called when calculating the base gold gain after combat
      combatEndGoldGain: (oppParty) ->
        @base.combatEndGoldGain = 0
        @self.personalityReduce 'combatEndGoldGain', [@self, oppParty, @base.combatEndGoldGain], @base.combatEndGoldGain

      ##TAG:REDUCTION: combatEndXpLoss | gold/100 | self, baseCombatEndGoldLoss | Called when calculating the base gold loss after combat
      combatEndGoldLoss: ->
        @base.combatEndGoldLoss = Math.floor @self.gold.getValue() / 100
        @self.personalityReduce 'combatEndGoldLoss', [@self, @base.combatEndGoldLoss], @base.combatEndGoldLoss

      ##TAG:REDUCTION: itemFindRange | (level+1)*itemFindRangeMultiplier | self, baseItemFindRange | Called when a player finds or attempts to equip a new item
      itemFindRange: ->
        baseRange = (@self.level.getValue()+1) * Constants.defaults.player.defaultItemFindModifier
        @base.itemFindRange = baseRange * @self.calc.itemFindRangeMultiplier()
        @base._upperlimitItemFindRange = baseRange * @base.itemFindRangeMultiplier
        @self.personalityReduce 'itemFindRange', [@self, @base.itemFindRange], @base.itemFindRange

      ##TAG:REDUCTION: itemFindRangeMultiplier | 1+(0.2*level/10) | self, baseItemFindRangeMultiplier | Called when a player finds or attempts to equip a new item
      itemFindRangeMultiplier: ->
        @base.itemFindRangeMultiplier = 1 + (0.2 * Math.floor @self.level.getValue()/10)
        @self.personalityReduce 'itemFindRangeMultiplier', [@self, @base.itemFindRangeMultiplier], @base.itemFindRangeMultiplier

      ##TAG:REDUCTION: itemScore | item.score() | self, item, baseItemScore | Called when checking the score of a new-found item
      itemScore: (item) ->
        if not item?.score and not item?._calcScore then @self.playerManager.game.errorHandler.captureError (new Error "Bad item for itemScore calculation"), extra: item
        baseValue = item?.score?() or item?._calcScore or 0
        (Math.floor @self.personalityReduce 'itemScore', [@self, item, baseValue], baseValue) + @self.itemPriority item

      ##TAG:REDUCTION: totalItemScore | all item scores | none | Called when calculating the score of a party
      totalItemScore: ->
        _.reduce @self.equipment, ((prev, item) =>
          if not item?.score and not item?._calcScore then @self.playerManager.game.errorHandler.captureError (new Error "Bad item for totalItemScore calculation"), extra: item
          prev+(item?.score?() or item?._calcScore or 0)
        ), 0

      ##TAG:REDUCTION: itemReplaceChancePercent | 100 | self, baseItemReplaceChancePercent | Called when seeing if the player will swap items
      itemReplaceChancePercent: ->
        @base.itemReplaceChancePercent = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'itemReplaceChancePercent', [@self, @base.itemReplaceChancePercent], @base.itemReplaceChancePercent

      ##TAG:REDUCTION: eventFumble | 25 | self, baseEventFumblePercent | Called when determining if an event should fumble. Most event fumbles mean the difference between a % boost and a static number boost.
      eventFumble: ->
        @base.eventFumble = 25
        @self.personalityReduce 'eventFumble', [@self, @base.eventFumble], @base.eventFumble

      ##TAG:REDUCTION: eventModifier | 0 | self, eventObject, baseEventModifier | Called before doing any kind of event so the probability can be adjusted
      eventModifier: (event) ->
        @base.eventModifier = 0
        @self.personalityReduce 'eventModifier', [@self, event, @base.eventModifier], @base.eventModifier

      ##TAG:REDUCTION: skillCrit | 1 | self, spellObject, baseSkillCrit | Called when casting any spell to see if it should be modified
      skillCrit: (spell) ->
        @base.skillCrit = 1
        @self.personalityReduce 'skillCrit', [@self, spell, @base.skillCrit], @base.skillCrit

      ##TAG:REDUCTION: itemSellMultiplier | 0.05 (5%) | self, item, baseItemSellMultiplier | Called when selling an item
      itemSellMultiplier: (item) ->
        @base.itemSellMultiplier = 0.05
        @self.personalityReduce 'itemSellMultiplier', [@self, item, @base.itemSellMultiplier], @base.itemSellMultiplier

      ##TAG:REDUCTION: damageTaken | 0 | self, attacker, damageTotal, skillType, spellObject, reductionType | Called when any damage is taken
      damageTaken: (attacker, damage, skillType, spell, reductionType) ->
        baseValue = 0
        @self.personalityReduce 'damageTaken', [@self, attacker, damage, skillType, spell, reductionType], baseValue

      ##TAG:REDUCTION: cantAct | 0 | self, baseCantAct | Called when a spell stops a players turn
      cantAct: ->
        baseValue = 0
        @self.personalityReduce 'cantAct', [@self, baseValue], baseValue

      ##TAG:REDUCTION: cantActMessages | [] | self, baseCantActMessages | Called when a spell stops a players turn
      cantActMessages: ->
        baseValue = []
        @self.personalityReduce 'cantActMessages', [@self, baseValue], baseValue

      ##TAG:REDUCTION: luckBonus | varies | self, baseLuckBonus
      # for actual derivation of luckBonus, see function calcLuckBonusFromValue above | Called when the RNG is generating items or modifying skills
      luckBonus: ->
        @baseValue = @self.calcLuckBonusFromValue @self.calc.stat 'luck'
        @self.personalityReduce 'luckBonus', [@self, @baseValue], @baseValue

      ##TAG:REDUCTION: fleePercent | 0.1 (0.1%) | self, baseFleePercent | Called every turn in combat before other actions
      fleePercent: ->
        @base.fleePercent = 0.1
        Math.max 0, Math.min 100, @self.personalityReduce 'fleePercent', [@self, @base.fleePercent], @base.fleePercent

      ##TAG:REDUCTION: partyLeavePercent | 0.1 (0.1%, constant) | self, basePartyLeavePercent | Called every step on the map
      partyLeavePercent: ->
        @base.partyLeavePercent = Constants.defaults.player.defaultPartyLeavePercent
        Math.max 0, Math.min 100, @self.personalityReduce 'partyLeavePercent', [@self, @base.partyLeavePercent], @base.partyLeavePercent

      ##TAG:REDUCTION: classChangePercent | 100 | self, potentialNewClass, baseClassChangePercent | Called every time a player meets with a trainer
      classChangePercent: (potential) ->
        @base.classChangePercent = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'classChangePercent', [@self, potential, @base.classChangePercent], @base.classChangePercent

      ##TAG:REDUCTION: alignment | 0 | self, baseAlignment | Called mostly by the calendar to determine alignment-specific day boosts/reductions
      alignment: ->
        @base.alignment = 0
        Math.max -10, Math.min 10, @self.personalityReduce 'alignment', [@self, @base.alignment], @base.alignment

      ##TAG:REDUCTION: ascendChance | 100 | self, baseAscendChance | Called when stepping on stairs up
      ascendChance: ->
        @base.ascendChance = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'ascendChance', [@self, @base.ascendChance], @base.ascendChance

      ##TAG:REDUCTION: descendChance | 100 | self, baseDescendChance | Called when stepping on stairs down
      descendChance: ->
        @base.descendChance = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'descendChance', [@self, @base.descendChance], @base.descendChance

      ##TAG:REDUCTION: teleportChance | 100 | self, baseTeleportChance | Called when stepping on a non-guild teleport
      teleportChance: ->
        @base.teleportChance = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'teleportChance', [@self, @base.teleportChance], @base.teleportChance

      ##TAG:REDUCTION: fallChance | 100 | self, baseFallChance | Called when stepping on a hole
      fallChance: ->
        @base.fallChance = 100
        Math.max 0, Math.min 100, @self.personalityReduce 'fallChance', [@self, @base.fallChance], @base.fallChance

      ##TAG:REDUCTION: physicalAttackTargets | allEnemies | self, allEnemies, allCombatMembers | Called when making a physical attack to attempt to determine a better target
      physicalAttackTargets: (allEnemies, allCombatMembers) ->
        allEnemies = {probability: 100, result: allEnemies} if _.isArray allEnemies
        (@self.probabilityReduce 'physicalAttackTargets', [@self, allEnemies, allCombatMembers], allEnemies).result

      ##TAG:REDUCTION: magicalAttackTargets | allEnemies | self, allEnemies, allCombatMembers | Called when making a magical attack to attempt to determine a better target
      magicalAttackTargets: (allEnemies, allCombatMembers) ->
        allEnemies = {probability: 100, result: allEnemies} if _.isArray allEnemies
        (@self.probabilityReduce 'magicalAttackTargets', [@self, allEnemies, allCombatMembers], allEnemies).result

      ##TAG:REDUCTION: bossRechallengeTime | 60 (sec) | self, baseBossRechallengeTime, bossData | Called when challenging a boss
      bossRechallengeTime: (bossData) ->
        @base.bossRechallengeTime = 60
        @self.personalityReduce 'bossRechallengeTime', [@self, @base.bossRechallengeTime, bossData], @base.bossRechallengeTime


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
