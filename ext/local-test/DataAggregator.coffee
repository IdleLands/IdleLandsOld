
_ = require "lodash"
fs = require "fs"
requireDir = require "require-dir"

## load maps
Map = require "../../src/map/Map"

maps = {}

walk = (dir) ->
  results = []
  list = fs.readdirSync dir

  list.forEach (baseFileName) ->
    file = dir + '/' + baseFileName
    stat = fs.statSync file
    if stat and stat.isDirectory() then results = results.concat walk file
    else results.push map: (baseFileName.split(".")[0]), path: file

  results

_.each (walk "#{__dirname}/../../assets/map"), (mapObj) =>
  maps[mapObj.map] = new Map mapObj.path

## load spells

spellObj = requireDir "../../src/character/spells", recurse: yes

spells = []

loadSpells = (obj) =>
  for spellKey, spell of obj
    spells.push spell if _.isFunction spell
    loadSpells spell if not _.isFunction spell

loadSpells spellObj

## load collectibles

bosses = require "../../config/boss.json"
pets = require "../../config/pets.json"

collectibles = []
requiredCollectibles = []
for mapName, mapData of maps
  collectibles.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.type is "Collectible"), 'name')...
  requiredCollectibles.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.properties?.requireCollectible), (r) -> r.properties.requireCollectible)...

for bossName, bossData of bosses
  collectibles.push (_.map bossData.collectibles, 'name')...

for petName, petData of pets
  requiredCollectibles.push (petData.requirements.collectibles)...

_.each spells, (spell) ->
  _.each spell.tiers, (tier) ->
    requiredCollectibles.push tier?.collectibles...

module.exports = {maps, spells, collectibles, requiredCollectibles}