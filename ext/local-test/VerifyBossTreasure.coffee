
_ = require "lodash"

bosses = require "../../config/boss.json"
bossitems = require "../../config/bossitems.json"
treasure = require "../../config/treasure.json"

verifyExistence = (key, warnOnEmpty = yes, checkTreasure = yes) ->

  if _.isUndefined bossData[key]
    console.warn "#{boss} has no custom #{key}" if warnOnEmpty
    return

  for i in [0...bossData[key].length]
    item = bossData[key][i]

    throw new Error "#{item.name} does not have a dropPercent specified" if _.isUndefined item.dropPercent
    throw new Error "#{item.name} does not have a valid dropPercent (less than 0 or greater than 100)" if item.dropPercent < 0 or item.dropPercent > 100

    return if not checkTreasure

    if treasure[item.name]
      console.warn "#{item.name} is specified in treasure.json instead of bossitems.json"

    else
      throw new Error "#{item.name} is not in bossitems.json" if not bossitems[item.name]

for boss, bossData of bosses
  verifyExistence 'items'
  verifyExistence 'collectibles', no, no

console.log "All boss treasures seem to be in order."