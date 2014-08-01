
_ = require "underscore"

class Map
  gidMap:
    1: "StairsDown"
    2: "StairsUp"
    3: "BrickWall"
    4: "Grass"
    5: "Water"
    6: "Lava"
    7: "Tile"
    8: "Ice"
    9: "Forest"
    10: "Sand"
    11: "Swamp"
    12: "PurpleNPC"
    13: "RedNPC"
    14: "GreenNPC"
    15: "QuestionMark"
    16: "Tree"
    17: "Mountain"
    18: "Door"

  blockers: [16, 17, 3]
  interactables: [1, 2, 12, 13, 14, 15, 18]

  constructor: (path) ->
    @map = require path

    @tileHeight = @map.tileheight
    @tileWidth = @map.tilewidth

    @height = @map.height
    @width = @map.width

    @name = @map.properties.name

  #regions need a min level, max level (for monster generation)
  #as well as a top-left x,y and a bottom-right x,y and teleport coordinates for GM teleport
  #any floor that has a boss on it will cause all people in the dungeon to help

  getTile: (x, y) ->

    #layers[0] will always be the terrain
    #layers[1] will always be the blocking tiles
    #layers[2] will always be the interactable stuff
    tilePosition = (y*@width) + x
    {
      terrain: @gidMap[@map.layers[0].data[tilePosition]]
      blocked: @map.layers[1].data[tilePosition] in @blockers
      blocker: @gidMap[@map.layers[1].data[tilePosition]]
      object: _.findWhere @map.layers[2].objects, {x: @tileWidth*x, y: @tileHeight*(y+1)}
    }

  getFirstTile: (predicate) ->
    {
    object: _.findWhere @map.layers[2].objects, predicate
    }

module.exports = exports = Map