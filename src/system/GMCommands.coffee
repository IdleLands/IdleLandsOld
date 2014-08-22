
MessageCreator = require "./MessageCreator"
_ = require "underscore"

class GMCommands
  constructor: (@game) ->

  teleportLocation: (player, locationTitle) ->
    location = @lookupLocation locationTitle
    @teleport player, location.map, location.x, location.y, location.formalName

  teleport: (player, map, x, y, title = null) ->
    return if not player
    player.map = map
    player.x = x
    player.y = y

    text = title ? "#{map} - #{x},#{y}"

    @game.teleport player, map, x, y, "#{player.name} got whisked away to #{text}."

  massTeleportLocation: (locationTitle) ->
    location = @lookupLocation locationTitle
    console.log "MTL: #{locationTitle} #{location}"
    @massTeleport location.map, location.x, location.y, locationTitle

  massTeleport: (map, x, y, title = null) ->
    console.info "MT: ",_.map @game.playerManager.players, (player) -> player.name
    _.each @game.playerManager.players, (player) =>
      @teleport player, map, x, y, title

  lookupLocation: (name) ->
    @locations[name]

  locations:
    "start":
      map: "Norkos"
      formalName: "the Start Location"
      x: 10
      y: 10
    "cleric":
      map: "Norkos"
      formalName: "the Cleric Trainer"
      x: 38
      y: 23
    "fighter":
      map: "Norkos"
      formalName: "the Fighter Trainer"
      x: 43
      y: 23
    "mage":
      map: "Norkos"
      formalName: "the Mage Trainer"
      x: 47
      y: 23
    "barbarian":
      map: "Norkos"
      formalName: "the Barbarian Trainer"
      x: 112
      y: 14
    "bard":
      map: "Bard Island -1"
      formalName: "the Bard Trainer"
      x: 4
      y: 4
    "jail":
      map: "Norkos"
      formalName: "Jail"
      x: 13
      y: 44

module.exports = exports = GMCommands