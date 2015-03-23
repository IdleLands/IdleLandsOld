console.log "travis_fold:start:pet_analysis"
console.log "Pet Analysis"

_ = require "lodash"
_.str = require "underscore.string"

pets = require "../../config/pets.json"

getPetCost = (petData) ->
  ret = 0
  ret += (_.reduce arr, ((prev, cur) -> prev+cur)) for attr, arr of petData.scaleCost
  ret

getNumPetUpgrades = (petData) ->
  ret = 0
  ret += arr.length for attr, arr of petData.scaleCost
  ret

xpCalc = (level) -> Math.floor 100 + (400 * Math.pow level, 1.71)

getPetInfo = (petData) ->
  scale = petData.scale
  minXpPerLevel = scale.xpPerGold[0]
  maxXpPerLevel = scale.xpPerGold[scale.xpPerGold.length-1]
  maxLevel      = scale.maxLevel[scale.maxLevel.length-1]

  xpNeeded = 0
  xpNeeded += xpCalc level for level in [1...maxLevel]

  minXpCost: Math.floor xpNeeded/minXpPerLevel
  maxXpCost: Math.floor xpNeeded/maxXpPerLevel
  totalXpNeeded: xpNeeded
  maxLevel: maxLevel

sortedPets = _.sortBy (_.keys pets)
_.each sortedPets, (pet) ->

  petData = pets[pet]

  upgradeCost = getPetCost petData
  petInfo = getPetInfo petData

  console.log "\n#{pet} (#{petData.category})"
  console.log "Max Level: #{petInfo.maxLevel} | XP Needed: #{_.str.numberFormat petInfo.totalXpNeeded}"
  console.log "#{_.str.numberFormat upgradeCost} gold spread across #{getNumPetUpgrades petData} upgrades"
  console.log "Min Gold (Feed): #{_.str.numberFormat petInfo.minXpCost} | Max Gold (Feed): #{_.str.numberFormat petInfo.maxXpCost}"
  console.log "Min Total Cost: #{_.str.numberFormat (petInfo.minXpCost+upgradeCost)} | Max Total Cost: #{_.str.numberFormat (petInfo.maxXpCost+upgradeCost)}"

console.log "travis_fold:end:pet_analysis"