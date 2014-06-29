
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
      min: 1
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
      min: 1
      max: 750
    ,
      type: "forsakeGold"
      min: 1
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
    blessGold:
      amount: 1000
    forsakeGold:
      amount: 1000
    blessItem:
      amount: 1
      percent: 5
    forsakeItem:
      amount: -1
      percent: -5

  @pickRandomEvent = (player) ->
    eventMod = 0
    event = @eventRates[chance.integer {min: 0, max: @eventRates.length-1}]
    prob = chance.integer {min: 0, max: event.max}
    return event.type if prob <= (event.min+eventMod)
    return null

module.exports = exports = Constants