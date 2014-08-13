
Spell = require "../base/Spell"

class LitanyOfPain extends Spell
  name: "Litany of Pain"
  @element = LitanyOfPain::element = Spell::Element.energy
  @cost = LitanyOfPain::cost = 300
  @restrictions =
    "Bard": 15

  calcDuration: -> super()+3
  
  calcDamage: ->
    @chance.integer min: (@caster.calc.stat 'int')/5, max: Math.max ((@caster.calc.stat 'int')/5)+1,(@caster.calc.stat 'int')/3

  determineTargets: ->
    @targetFriendlies()

  cast: (player) ->
    message = "#{@caster.name} begins playing \"#{@name}\" at #{player.name}!"
    @broadcast message

  tick: (player) ->
    if((@chance.integer min: (Math.min 0,-(@caster.calc.stat 'wis')), max: (Math.max 0,(player.calc.stats ['agi', 'dex']/2))) < 0)
      damage = @calcDamage()
      message = "#{player.name} is damaged by #{@caster.name}'s \"#{@name}\" for #{damage} HP damage"
      @caster.party?.currentBattle?.takeHp @caster, player, damage, @determineType(), message

  uncast: (player) ->
    return if @caster isnt player
    message = "#{player.name} is no longer under the effects of \"#{@name}.\""
    @broadcast message

  constructor: (@game, @caster) ->
    super @game, @caster
    @bindings =
      doSpellCast: @cast
      doSpellUncast: @uncast
      "combat.self.turn.end": @tick

module.exports = exports = LitanyOfPain