
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

class Constants
  @gameName = "Idletopia"
  @eventRates = [

    #  type: "yesno"
    #  min: 0 #turned off until I know what they're good for
    #  max: 1000
    #,
      type: "findItem"
      min: 300
      max: 300
    ,
      type: "blessItem"
      min: 1
      max: 500
    ,
      type: "forsakeItem"
      min: 1
      max: 750
    ,
      type: "blessXp"
      min: 1
      max: 350
    ,
      type: "forsakeXp"
      min: 1
      max: 750
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
      min: 600
      max: 750
    ,
      type: "battle"
      min: 100
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

  @defaults =
    maxPartySize: 3

    player:
      defaultYesPercent: 50
      defaultPartyLeavePercent: 1

  @pickRandomEvent = (player) ->
    event = _.sample @eventRates
    eventMod = player.personalityReduce 'eventModifier', [event], 0
    prob = chance.integer {min: 0, max: event.max}
    return event.type if prob <= (event.min+eventMod)
    null

module.exports = exports = Constants