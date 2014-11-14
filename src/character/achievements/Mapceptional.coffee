
Achievement = require "../base/Achievement"
{toRoman} = require "roman-numerals"
_ = require "underscore"

class Mapceptional extends Achievement

  getAllAchievedFor: (player) ->
    baseStat = player.statistics['calculated map changes']

    possibilities = [
      {mapName: "Norkos +1", reward: "+20 CON", con: -> 20}
      {mapName: "Norkos -11", reward: "+100 CON", con: -> 100}
    ]

    achieved = []

    _.each possibilities, (possibility) ->
      return if not baseStat[possibility.mapName]
      baseItem =
        name: "Mapceptional: #{possibility.mapName}"
        desc: "Travel to #{possibility.mapName}"
        type: "exploration"

      fullItem = _.extend baseItem, possibility
      achieved.push fullItem

    achieved


module.exports = exports = Mapceptional