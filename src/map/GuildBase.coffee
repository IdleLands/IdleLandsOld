
_ = require "lodash"
chance = new (require "chance")()

Map = require "./Map"

class GuildBase extends Map
  constructor: (name, game) ->
    super "#{__dirname}/../../assets/guildhall-base/#{name}.json", game

  dimensions:
    sm: 3
    md: 5
    lg: 7

  instances:
    sm: []
    md: []
    lg: []

module.exports = exports = GuildBase