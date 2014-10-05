
Spell = require "../../../base/Spell"

class NinetyNineBottles extends Spell
  name: "99 Bottles of Ale"
  @element = NinetyNineBottles ::element = Spell::Element.physical
  @cost = NinetyNineBottles::cost = 0 #500
  @stat = NinetyNineBottles::stat = "hp"
  @restrictions =
    "Pirate": 1
#23

  calcDamage: ->
    missingNines = Math.floor((99 - @caster.special.getValue())/9)
    baseDamage = (@caster.calc.stat 'str')*(0.5+0.05*missingNines)
    minStat = baseDamage*0.8
    maxStat = baseDamage*1.25
    super() + @minMax minStat, maxStat

  determineTargets: -> @targetSomeEnemies size: 1

  cast: (player) ->
    message = "%casterName throws some of his %spellName at %targetName!"
    @broadcast player, message
    toThrow = @chance.integer({min: 8, max: 8 + @caster.level.getValue()})
    if @caster.special.lessThan toThrow
      toThrow = @caster.special.getValue()
    @caster.profession.drunkPct.add Math.floor(toThrow*0.02*@chance.integer({min: 80, max: 125}))
    while toThrow >= 9
      damage = @calcDamage()
      message = "%casterName throws 9 bottles at %targetName, dealing %damage damage!"
      @doDamageTo player, damage, message
      @caster.special.sub 9
      toThrow -= 9
    if toThrow
      if @caster.special.lessThan toThrow
        toThrow = @caster.special.getValue()
      damage = Math.ceil(@calcDamage()*toThrow/9)
      message = "%casterName throws #{toThrow} bottles at %targetName, dealing %damage damage!"
      @doDamageTo player, damage, message
      @caster.special.sub toThrow
      toThrow = 0

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast

module.exports = exports = NinetyNineBottles