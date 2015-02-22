console.log "\n>>> TREASURE ANALYSIS"

_ = require "lodash"
_.str = require "underscore.string"

Equipment = require "../../src/item/Equipment"

bosses = require "../../config/boss.json"
bossitems = require "../../config/bossitems.json"
treasure = require "../../config/treasure.json"

allTreasure = []

perc = (min, max) ->
  Math.floor min/max*100

for bossName, bossData of bosses
  _.each bossData.items, (itemProto) ->
    item = new Equipment bossitems[itemProto.name]
    allTreasure.push {source: "Boss", type: item.type, score: item.score()}

for treasureName, treasureData of treasure
  item = new Equipment treasureData
  allTreasure.push {source: "Chest", type: item.type, score: item.score()}

sortedBySlot    = _.countBy allTreasure, 'type'
sortedBySource  = _.countBy allTreasure, 'source'
countBySlotType = _.reduce (_.keys sortedBySlot), (prev, slot) ->
                    prev[slot] = _(allTreasure).filter((item) -> item.type is slot).countBy('source').value()
                    prev
                  , {}

console.log "\nAll Treasure Sources"

_.each (_.keys sortedBySource), (source) ->
  header = _.str.pad source, 10
  console.log "#{header}:\t#{sortedBySource[source]} (#{perc sortedBySource[source], allTreasure.length}%)"

console.log "\nTreasure Counts (Overall)"

_.each (_.keys sortedBySlot), (slot) ->
  header = _.str.pad slot, 10
  console.log "#{header}:\t#{sortedBySlot[slot]}\t(#{perc sortedBySlot[slot], allTreasure.length}%)"

console.log "\nTreasure Acquisition By Slot"

_.each (_.keys sortedBySlot), (slot) ->
  header = _.str.pad slot, 10
  start = "#{header}:"
  _.each (_.keys sortedBySource), (source) ->

    start = "#{start}\t#{source}: #{countBySlotType[slot][source] or 0} (#{perc (countBySlotType[slot][source] or 0), sortedBySlot[slot]}%)"

  console.log start

console.log ""