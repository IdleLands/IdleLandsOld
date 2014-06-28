
_ = require "underscore"
Chance = require "chance"
chance = new Chance()

class Constants
  @gameName = "Idletopia"
  @eventRates =

    yesno:
      min: 15
      max: 100

    findItem:
      min: 1
      max: 100
    blessItem:
      min: 1
      max: 100
    forsakeItem:
      min: 1
      max: 100

    blessXp:
      min: 1
      max: 100
    forsakeXp:
      min: 1
      max: 100

    blessGold:
      min: 1
      max: 100
    forsakeGold:
      min: 1
      max: 100

    party:
      min: 1
      max: 100

    battle:
      min: 1
      max: 100

  @pickRandomEvent = ->
    "yesno"

module.exports = exports = Constants