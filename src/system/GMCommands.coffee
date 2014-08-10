
MessageCreator = require "./MessageCreator"
_ = require "underscore"

class GMCommands
  constructor: (@game) ->

  teleportLocation: (player, locationTitle) ->
    location = @lookupLocation locationTitle
    @teleport player, location.map, location.x, location.y, locationTitle

  teleport: (player, map, x, y, title = null) ->
    return if not player
    player.map = map
    player.x = x
    player.y = y

    text = title ? "#{map} - #{x},#{y}"

    @game.teleport player, map, x, y, "#{player.name} got whisked away to #{text}."

  massTeleportLocation: (locationTitle) ->
    location = @lookupLocation locationTitle
    @massTeleport location.map, location.x, location.y, locationTitle

  massTeleport: (map, x, y, title = null) ->
    _.forEach @game.playerManager.players, (player) =>
      @teleport player, map, x, y, title

  lookupLocation: (name) ->
    @locations[name]

  locations:
    "start":
      map: "Norkos"
      x: 10
      y: 10
    "cleric":
      map: "Norkos"
      x: 38
      y: 23
    "fighter":
      map: "Norkos"
      x: 43
      y: 23
    "mage":
      map: "Norkos"
      x: 47
      y: 23
    "barbarian":
      map: "Norkos"
      x: 112
      y: 14

module.exports = exports = GMCommands