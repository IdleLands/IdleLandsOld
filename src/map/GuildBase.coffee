
_ = require "lodash"
chance = new (require "chance")()

Map = require "./Map"

class GuildBase extends Map
  constructor: (name, game, @guild) ->
    super "#{__dirname}/../../assets/guildhall-base/#{name}.json", game

  dimensions:
    sm: 3
    md: 5
    lg: 7

  baseTile: 0

  instances:
    sm: []
    md: []
    lg: []

  buildings:
    sm: []
    md: []
    lg: []

  getMapData: ->
    _.omit super(), 'instances', 'guild'

  build: (building, size, slot, instance) ->
    slotData = @buildings[size][slot]

    {startCoords, signpostLoc, tiles} = slotData

    tileIndices = []
    tileCoords = []
    dim = @dimensions[size]
    mapWidth = @map.width

    for i in [0...dim]
      startLeft = ((i+startCoords[1])*mapWidth)+startCoords[0]
      tileIndices = tileIndices.concat [startLeft..startLeft+dim-1]
      tileCoords.push x: startCoords[0]+j, y: i+startCoords[1] for j in [0...dim]

    _.each tileIndices, (index, myLookup) =>
      @map.layers[0].data[index] = instance.baseTile or @baseTile
      @map.layers[1].data[index] = tiles[myLookup] if tiles[myLookup] > 0

    @map.layers[2].objects = _.reject @map.layers[2].objects, (item) -> _.contains tileIndices, (item.y/16)*mapWidth + item.x/16

    sign = _.findWhere @map.layers[2].objects, {x: signpostLoc[0]*16, y: signpostLoc[1]*16}

    if not sign
      @map.layers[2].objects.push
        gid: 48
        height: 0
        width: 0
        name: "Level #{@guild.buildingLevels[building]} #{building}"
        properties:
          flavorText: instance.desc
        type: "Sign"
        visible: yes
        x: signpostLoc[0]*16
        y: (1+signpostLoc[1])*16

    else
      sign.name = "Level #{@guild.buildingLevels[building]} #{building}"
      sign.properties.flavorText = instance.desc

    _.each instance.tiles, (tile, index) =>
      return if tile is 0
      gid = if _.isObject tile then tile.gid else tile
      newObject =
        gid: gid
        height: 0
        width: 0
        visible: yes
        x: tileCoords[index].x*16
        y: (1+tileCoords[index].y)*16
        properties: {}

      _.merge newObject, tile if _.isObject tile

      @map.layers[2].objects.push newObject

    # remove old interactables (find any that is on one of the tiles above)
    # add sign if not exists
    # update sign
    # allow for building over another building

module.exports = exports = GuildBase