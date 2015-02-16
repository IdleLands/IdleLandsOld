
_ = require "lodash"
chance = new (require "chance")()
Constants = require "../system/utilities/Constants"

class Map
  gidMap: Constants.gidMap

  blockers: [16, 17, 3, 33, 37, 38, 39, 44, 45, 46, 47, 50, 53, 54, 55]
  interactables: [1, 2, 12, 13, 14, 15, 18, 40, 41, 42, 43, 48, 51]

  constructor: (path, @game) ->
    @map = require path

    @tileHeight = @map.tileheight
    @tileWidth = @map.tilewidth

    @height = @map.height
    @width = @map.width

    @name = @map.properties.name

    @loadRegions()
    @nameTrainers()

  loadRegions: ->
    @regionMap = []

    return if not @map.layers[3]

    _.each @map.layers[3].objects, (region) =>
      startX = region.x / 16
      startY = region.y / 16
      width = region.width / 16
      height = region.height / 16

      for x in [startX...(startX+width)]
        for y in [startY...(startY+height)]
          @regionMap[(y*@width)+x] = region.name

  nameTrainers: ->
    return unless @game
    @game.loading.then =>
      allTrainersOnMap = (_.filter @map.layers[2].objects, (obj) -> obj.type is "Trainer")
      _.each allTrainersOnMap, (trainer) =>
        possibleNames = _.reject @game.componentDatabase.npcs, (npc) -> npc.class and npc.class isnt trainer.name
        chancedName = chance.name {middle: chance.bool(), prefix: chance.bool(), suffix: chance.bool()}
        npcName = (_.sample possibleNames).name
        trainer.properties.realName = if chance.bool({likelihood: 30}) then chancedName else npcName

  getMapData: ->
    _.omit @, 'game'

  getTile: (x, y) ->

    #layers[0] will always be the terrain
    #layers[1] will always be the blocking tiles
    #layers[2] will always be the interactable stuff
    #layers[3] will always be map regions, where applicable
    tilePosition = (y*@width) + x

    tileObject = _.findWhere @map.layers[2].objects, {x: @tileWidth*x, y: @tileHeight*(y+1)}

    {
      terrain: @gidMap[@map.layers[0].data[tilePosition]]
      blocked: @map.layers[1].data[tilePosition] in @blockers
      blocker: @gidMap[@map.layers[1].data[tilePosition]]
      region: @regionMap[tilePosition] or 'Wilderness'
      object: tileObject
    }

  getFirstTile: (predicate) ->
    {
    object: _.findWhere @map.layers[2].objects, predicate
    }

module.exports = exports = Map