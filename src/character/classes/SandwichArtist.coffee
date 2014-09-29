# test: inst().playerManager.getPlayerByName('Danret').changeProfession('Jester')
Class = require "./../base/Class"

class SandwichArtist extends Class

  baseHp: 40
  baseHpPerLevel: 12
  baseHpPerCon: 5

  baseMp: 8
  baseMpPerLevel: 3
  baseMpPerInt: 2

  baseConPerLevel: 1
  baseDexPerLevel: 5
  baseAgiPerLevel: 1
  baseStrPerLevel: 3
  baseIntPerLevel: 1
  baseWisPerLevel: 1

  itemScore: (player, item) ->
    item.dex*2 +
    item.str*0.8 -
    item.int

  physicalAttackChance: -> -10

  minDamage: (player) ->
    player.calc.damage()*0.15
	
  events: {}

  load: (player) ->
    super player
    player.special.maximum = 999999
	# This doesn't hide it
    player.special.name = ""

    player.on "combat.round.start", @events.roundstart = -> player.special.set Math.floor(Math.random()*1000000)

  unload: (player) ->
    player.special.maximum = 0
    player.special.name = ""

    player.off "sombat.round.start", @events.roundstart

module.exports = exports = SandwichArtist
 