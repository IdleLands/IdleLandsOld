
_ = require "lodash"

bossparties = require "../../config/bossparties.json"
bosses = require "../../config/boss.json"

for party, partyData of bossparties
  for i in [0...partyData.members.length]
    boss = partyData.members[i]
    throw new Error "Boss (#{boss}) does not exist." if not bosses[boss]

console.log "All bossparties seem to have bosses that exist."