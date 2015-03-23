console.log "travis_fold:start:collectible_analysis"
console.log "Collectible Analysis"

_ = require "lodash"
_.str = require "underscore.string"

{collectibleObjs} = require "../local-test/DataAggregator"

validCollectibles = _.sortBy (_.filter collectibleObjs, (collectible) -> collectible.flavorText), 'name'

maxLeft = (_.max validCollectibles, (collectible) -> collectible.name.length).name.length

_.each validCollectibles, (collectible) ->
  story = collectible.storyline or "none"
  console.log "#{(_.str.pad collectible.name, maxLeft)}\t(#{story}) #{collectible.flavorText}"

console.log "travis_fold:end:collectible_analysis"