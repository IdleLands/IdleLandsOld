console.log "travis_fold:start:verify_pets"

_ = require "lodash"

pets = require "../../../config/pets.json"
bosses = require "../../../config/boss.json"

for pet, petData of pets
  throw new Error "Invalid pet type: #{petData.category} (#{pet})" unless (petData.category in ['Hybrid', 'Non-Combat', 'Combat'])
  throw new Error "No requirements specified (#{pet})" if 0 is _.size petData.requirements
  throw new Error "No description specified (#{pet})" unless petData.description

  _.each petData.requirements.bosses, (bossReq) ->
    throw new Error "Required boss kill for #{pet} (#{bossReq}) does not exist." unless bosses[bossReq]

  for scaleVal, scaleArr of petData.scale
    throw new Error "Incompatible array sizes for #{scaleVal} (#{pet})" if petData.scaleCost[scaleVal].length isnt scaleArr.length

console.log "All pets seem to be declared correctly."
console.log "travis_fold:end:verify_pets"