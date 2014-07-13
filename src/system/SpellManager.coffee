###
  spells have a base but can critically be modified

  so if you critically cast a fireball, you could get...
  glowing fireball
  glacial fireball
  crappy fireball

  ..etc

  spell elements:

  plain, normal, ordinary, obvious, conspicuous

  fire, water, thunder, ice, earth

  warm, embered, flaming, blazing, supernova
  moist, wet, soaked, tidal, monsoon
  static, shocking, jolting, bolting, storming
  cold, chilled, frozen, arctic, glacial
  dirty, pebbled, rocky, boulder, avalanche
###
_ = require "underscore"
requireDir = require "require-dir"
spells = requireDir "../character/spells"

class SpellManager
  constructor: (@game) ->
    @loadSpells()

  loadSpells: ->
    @spells.push spell for spell of spells

SpellManager::getSpellsAvailableFor = (player) ->
  _.filter @spells, (spell) ->
    realSpell = spells[spell]
    player.professionName of realSpell.restrictions and
      player.level.getValue() >= realSpell.restrictions[player.professionName] and
      player[realSpell.stat].getValue() >= realSpell.cost
  .map (spell) -> spells[spell]

SpellManager::spells = []

# Constants.spellModifyPercent
SpellManager::modifySpell = (spell) -> spell

module.exports = exports = SpellManager