
_ = require "lodash"

pets = require "../../config/pets.json"

for pet, petData of pets
  throw new Error "Invalid pet type: #{petData.category} (#{pet})" if not (petData.category in ['Hybrid', 'Non-Combat', 'Combat'])
  throw new Error "No requirements specified (#{pet})" if 0 is _.size petData.requirements
  throw new Error "No description specified (#{pet})" if not petData.description

  for scaleVal, scaleArr of petData.scale
    throw new Error "Incompatible array sizes for #{scaleVal} (#{pet})" if petData.scaleCost[scaleVal].length isnt scaleArr.length

console.log "All pets seem to be declared correctly."