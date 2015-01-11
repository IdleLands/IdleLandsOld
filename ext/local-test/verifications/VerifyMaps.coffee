Map = require "../../../src/map/Map"
_ = require "lodash"
fs = require "fs"

bossparties = require "../../../config/bossparties.json"
bosses = require "../../../config/boss.json"
treasures = require "../../../config/chests.json"
teleports = require "../../../config/teleports.json"
teleLocs = _.extend {},
  teleports.towns,
  teleports.bosses,
  teleports.dungeons,
  teleports.trainers,
  teleports.other

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

inBounds = (x1, y1, x2, y2) ->
  return no if x1 < 0 or y1 < 0
  return yes if x1 < x2 and y1 < y2

for teleName, teleData of teleLocs
  teleMap = maps[teleData.map]
  tileData = teleMap.getTile teleData.x, teleData.y
  throw new Error "Teleport (#{teleName}) not in map bounds" if not inBounds teleData.x, teleData.y, teleMap.width, teleMap.height
  throw new Error "Teleport (#{teleName}) lands on a dense tile" if tileData.blocked

allBossesOnMaps = []
allTreasureOnMaps = []
allTeleportsOnMaps = []
for mapName, mapData of maps
  allBossesOnMaps.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.type in ["Boss", "BossParty"]), 'name')...
  allTreasureOnMaps.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.type is "Treasure"), 'name')...
  allTeleportsOnMaps.push (_.map (_.filter mapData.map.layers[2].objects, (obj) -> obj.type is "Teleport"), 'properties')...

allBossesInParties = []
for partyName, partyData of bossparties
  allBossesInParties.push partyData.members...

  throw new Error "BossParty (#{partyName}) not on map" if not _.contains allBossesOnMaps, partyName

for bossName, bossData of bosses
  continue if _.contains allBossesInParties, bossName

  throw new Error "Boss (#{bossName}) not on map" if not _.contains allBossesOnMaps, bossName

for treasureName, treasureData of treasures
  throw new Error "Treasure (#{treasureName}) not on map" if not _.contains allTreasureOnMaps, treasureName

for teleport in allTeleportsOnMaps


  [teleport.destx, teleport.desty, teleport.map] = [t.x, t.y, t.map] if (t = teleLocs[teleport.toLoc])

  teleMap = maps[teleport.map]
  teleName = JSON.stringify teleport
  tileData = teleMap.getTile (parseInt teleport.destx), (parseInt teleport.desty)
  throw new Error "Teleport (#{teleName}) not in map bounds" if not inBounds teleport.destx, teleport.desty, teleMap.width, teleMap.height
  throw new Error "Teleport (#{teleName}) lands on a dense tile" if tileData.blocked
  throw new Error "Teleport (#{teleName}) does not have a valid teleport type" if not teleport.movementType in ['teleport', 'ascend', 'descend', 'fall']

console.log "All map data seems to be correct"