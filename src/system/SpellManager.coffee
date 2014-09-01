
_ = require "underscore"
requireDir = require "require-dir"
spells = requireDir "../character/spells", recurse: yes
Spell = require "../character/base/Spell"
chance = new (require "chance")()

class SpellManager
  constructor: (@game) ->
    @loadSpells()

  loadSpells: ->
    loadSpellObject = (obj) =>
      for spellKey, spell of obj
        @spells.push spell if _.isFunction spell
        loadSpellObject spell if not _.isFunction spell

    loadSpellObject spells

SpellManager::getSpellsAvailableFor = (player) ->
  _.filter @spells, (realSpell) ->

    realSpell.cost = realSpell.cost.bind null, player if _.isFunction realSpell.cost

    (player.professionName of realSpell.restrictions) and
    (player.level.getValue() >= realSpell.restrictions[player.professionName]) and
    (player[realSpell.stat].getValue() >= _.result realSpell, 'cost') and
    (realSpell.canChoose player)

SpellManager::spells = []

SpellManager::spellMods =
  'ice': ['cold', 'chilled', 'frozen', 'arctic', 'glacial']
  'fire': ['warm', 'embering', 'flaming', 'blazing', 'supernova-ing']
  'water': ['moist', 'wet', 'soaked', 'tidal', 'monsoon-y']
  'thunder': ['static', 'shocking', 'jolting', 'bolting', 'storming']
  'earth': ['dirty', 'pebbly', 'rocky', 'boulder-y', 'avalanche-y']
  'holy': ['cheesy', 'pure', 'blessed', 'holy', 'godly']

  'energy': ['weak', 'able', 'powerful', 'oh-so-magical', 'solar']
  'heal': ['mending', 'alleviating', 'healing', 'blessing', 'restoring']
  # 'buff': ['abrupt', 'short', 'medium', 'long', 'eternal']

  'physical': ['plain', 'normal', 'ordinary', 'obvious', 'conspicious']

# Constants.spellModifyPercent
SpellManager::modifySpell = (spell) ->
  doMod = chance.bool likelihood: Math.max 0, (Math.min 100, (spell.caster.calc.skillCrit spell)+(spell.caster.calc.stat 'luck'))
  return spell if not doMod

  probs = [100, 50, 20, 5, 1]

  element = _.sample _.keys SpellManager::spellMods
  strength = 0
  newName = spell.name
  for prob in [(probs.length-1)..0]
    if (chance.bool {likelihood: probs[prob]})
      strength = prob
      newName = "#{SpellManager::spellMods[element][prob]} #{spell.name}"

  spell.name = newName
  spell.element |= Spell::Element[element]
  spell.bonusElement = Spell::Element[element]
  spell.bonusElementRanking = strength
  spell

module.exports = exports = SpellManager