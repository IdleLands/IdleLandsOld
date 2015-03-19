console.log "travis_fold:start:boss_info"

_ = require "lodash"
_.str = require "underscore.string"

bosses = require "../../config/boss.json"

bossImportant = []

bossImportant.push {class: bossData.stats.class, level: bossData.stats.level} for bossName, bossData of bosses

overallClass = _.countBy bossImportant, 'class'

perc = (min, max) ->
  Math.floor min/max*100

console.log "\nBoss Class Breakdown (All)"
classKeys = _.keys overallClass
_.each (_.sortBy classKeys), (key) ->
  console.log "#{_.str.pad key, 15}:\t#{overallClass[key]}\t(#{perc overallClass[key], classKeys.length}%)"

console.log "\nBoss Level Range Breakdown (All)"

RANGE_GRANULARITY = 5

overallExist = _.countBy bossImportant, (boss) -> RANGE_GRANULARITY*(Math.floor boss.level/RANGE_GRANULARITY)
levelKeys = _.keys overallExist

_.each levelKeys, (key) ->
  level = parseInt key
  header = _.str.pad "Level #{level}-#{level+RANGE_GRANULARITY-1}", 15
  console.log "#{header}:\t#{overallExist[key]}\t(#{perc overallExist[key], levelKeys.length}%)"
  
console.log "travis_fold:end:boss_info"
