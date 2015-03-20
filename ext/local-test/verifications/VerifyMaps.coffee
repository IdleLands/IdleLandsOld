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

{maps} = require "../DataAggregator"

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

  teleports = (_.filter mapData.map.layers[2].objects, (obj) -> obj.type is "Teleport")
  _.each teleports, (port) ->
    port.origin = mapName
    _.extend port, port.properties

  allTeleportsOnMaps.push teleports...

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

  teleName = "#{teleport.name} - #{teleport.x/16},#{teleport.y/16} (on #{teleport.origin})"

  try
    teleMap = maps[teleport.map]
    tileData = teleMap.getTile (parseInt teleport.destx), (parseInt teleport.desty)
  catch
    throw new Error "Invalid teleport [#{teleName}] leads to #{teleport.map} - #{teleport.destx},#{teleport.desty} -- this map does not appear to exist."

  throw new Error "Teleport [#{teleName}] not in map bounds" if not inBounds teleport.destx, teleport.desty, teleMap.width, teleMap.height
  throw new Error "Teleport [#{teleName}] lands on a dense tile" if tileData.blocked

  throw new Error "Teleport [#{teleName}] does not have a valid teleport type" if not (teleport.movementType.toLowerCase() in ['teleport', 'ascend', 'descend', 'fall'])
  throw new Error "Teleport [#{teleName}] does not have a matching staircase" if (teleport.movementType in ['ascend', 'descend']) and tileData.object?.type isnt 'Teleport'

console.log "All map data seems to be correct."
