
_ = require "lodash"

teleports = require "../../config/teleports.json"

locations = {}

for i, tpParent of teleports
  for teleport, tpData of tpParent

    throw new Error "Duplicate teleport name (#{teleport}); first instance: #{JSON.stringify locations[teleport]}" if locations[teleport]
    locations[teleport] = tpData

    throw new Error "Teleport (#{teleport}) does not have enough properties. Expected 4, has #{_.size tpData}" if 4 > _.size tpData

console.log "All teleports seem to be valid."