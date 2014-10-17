
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

    playerTile = player.getTileAt()
    player.handleTile playerTile

  massTeleportLocation: (locationTitle) ->
    location = @lookupLocation locationTitle
    @massTeleport location.map, location.x, location.y, location.formalName

  massTeleport: (map, x, y, title = null) ->
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
    "jail":
      map: "Norkos"
      formalName: "Jail"
      x: 13
      y: 44

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
    "jester":
      map: "Norkos Dungeon -5"
      formalName: "the Jester Trainer"
      x: 39
      y: 43
    "rogue":
      map: "Norkos Prison -1"
      formalName: "the Rogue Trainer"
      x: 34
      y: 1
    "sandwichartist":
      map: "Norkos"
      formalName: "the Sandwich Artist Trainer"
      x: 54
      y: 122
    "pirate":
      map: "Norkos"
      formalName: "the Pirate Trainer"
      x: 219
      y: 49

    "fisheries":
      map: "Norkos"
      formalName: "the Fisheries"
      x: 35
      y: 70
    "boathouse":
      map: "Norkos"
      formalName: "the Boathouse"
      x: 10
      y: 88
    "prison":
      map: "Norkos"
      formalName: "Norkos Prison"
      x: 92
      y: 11

    "norkos":
      map: "Norkos"
      formalName: "Norkos"
      x: 34
      y: 14
    "maeles":
      map: "Norkos"
      formalName: "Maeles"
      x: 51
      y: 115
    "vocalnus":
      map: "Vocalnus"
      formalName: "Vocalnus"
      x: 51
      y: 35

    "goblinlord":
      map: "Norkos Dungeon -1"
      formalName: "the Goblin Lord"
      x: 41
      y: 14
    "mummylord":
      map: "Norkos Dungeon -3"
      formalName: "the Mummy Lord"
      x: 40
      y: 13
    "lizardking":
      map: "Norkos Dungeon -5"
      formalName: "the Lizard King"
      x: 4
      y: 4

module.exports = exports = GMCommands