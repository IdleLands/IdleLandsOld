
_ = require "lodash"

treasure = require "../../config/treasure.json"
chests = require "../../config/chests.json"

for chest, chestData of chests

  throw new Error "Chest (#{chest}) has no items." if chestData.items?.length is 0

  for i in [0...chestData.items.length]
    item = chestData.items[i]

    throw new Error "Item (#{item}) is not in treasure.json" if not treasure[item]

console.log "All chests seem to have vaild treasure."