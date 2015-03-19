
console.log "travis_fold:start:verify_collectibles"

_ = require "lodash"

bosses = require "../../../config/boss.json"

{spells, collectibles, requiredCollectibles} = require "../DataAggregator"

countedCollectibles = _.countBy collectibles

for name, count of countedCollectibles
  throw new Error "Collectible (#{name}) already exists" if count > 1

_.each requiredCollectibles, (req) ->
  throw new Error "Collectible (#{req}) is required but does not exist" unless _.contains collectibles, req

console.log "All collectible data seems to be correct."
console.log "travis_fold:end:verify_collectibles"