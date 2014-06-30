
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

class Constants
  @gameName = "Idletopia"
  @eventRates = [

      type: "yesno"
      min: 1
      max: 1000
    ,
      type: "findItem"
      min: 50
      max: 100
    ,
      type: "blessItem"
      min: 1
      max: 1500
    ,
      type: "forsakeItem"
      min: 1
      max: 1250
    ,
      type: "blessXp"
      min: 1
      max: 500
    ,
      type: "forsakeXp"
      min: 1
      max: 1000
    ,
      type: "blessGold"
      min: 500
      max: 750
    ,
      type: "forsakeGold"
      min: 999
      max: 1000
    ,
      type: "party"
      min: 1
      max: 100
    ,
      type: "battle"
      min: 1
      max: 100
  ]

  @eventEffects =
    blessXp:
      percent: 10
      amount: 100
    forsakeXp:
      percent: -10
      amount: -100
    blessGold: #got this much money? no problem, you don't need more.. probably :D
      amount: [1, 60, 100, 400, 1000, 3000, 7000, 10000, 25000, 50000, 65000, 85000, 100000]
    forsakeGold:
      amount: [-1, -60, -100, -400, -1000, -3000, -7000, -10000, -25000, -50000, -65000, -85000, -100000]
    blessItem:
      amount: 1
      percent: 5
    forsakeItem:
      amount: -1
      percent: -5

  @pickRandomEvent = (player) ->
    eventMod = 0
    event = _.sample @eventRates
    prob = chance.integer {min: 0, max: event.max}
    return event.type if prob <= (event.min+eventMod)
    return null

module.exports = exports = Constants