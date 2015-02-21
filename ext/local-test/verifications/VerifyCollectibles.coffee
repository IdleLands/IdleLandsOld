Map = require "../../../src/map/Map"
_ = require "lodash"
fs = require "fs"
requireDir = require "require-dir"

bosses = require "../../../config/boss.json"
spells = requireDir "../../../src/character/spells", recurse: yes

allSpells = []

loadSpells = (obj) =>
  for spellKey, spell of obj
    allSpells.push spell if _.isFunction spell
    loadSpells spell if not _.isFunction spell

loadSpells spells

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

_.each (walk "#{__dirname}/../../../assets/map"), (mapObj) =>
  maps[mapObj.map] = new Map mapObj.path

allCollectibles = []
allRequiredCollectibles = []
for mapName, mapData of maps
  allCollectibles.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.type is "Collectible"), 'name')...
  allRequiredCollectibles.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.properties?.requireCollectible), (r) -> r.properties.requireCollectible)...

for bossName, bossData of bosses
  allCollectibles.push (_.map bossData.collectibles, 'name')...

_.each allSpells, (spell) ->
  _.each spell.tiers, (tier) ->
    allRequiredCollectibles.push tier?.collectibles...

countedCollectibles = _.countBy allCollectibles

for name, count of countedCollectibles
  throw new Error "Collectible (#{name}) already exists" if count > 1

_.each allRequiredCollectibles, (req) ->
  throw new Error "Collectible (#{req}) is required but does not exist" unless _.contains allCollectibles, req

console.log "All collectible data seems to be correct"