_ = require "lodash"
Equipment = require "./Equipment"

class Usable extends Equipment

  constructor: (options) ->
    super options

  use: (player) ->
    # check if prepared
    # check if unidentified
    score()
    # TODO when using a potion for stats, add enchantLevel/20 and add it to the multiplier

    # increment uses

  score: ->
    super()
    @_calcScore += @triggerMults[@trigger] if @trigger

  @multipliers = _.extend @multipliers,
    charges: 75
    blessed: 200
    cursed: -500

  @triggerMults =
    "combat.self.kill": 100
    "combat.self.attacked": 275
    "combat.self.damaged": 300
    "combat.self.turn.start": 250
    "combat.self.turn.end": 250
    "combat.battle.start": 150

module.exports = exports = Usable
