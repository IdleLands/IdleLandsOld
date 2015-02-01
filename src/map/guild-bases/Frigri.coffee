GuildBase = require "../GuildBase"

`/**
 * This guild base is located in Frigri.
 *
 * @name Frigri
 * @category Locations
 * @package Guild Bases
 * @cost {move-in} 150000
 * @cost {build-sm} 70000
 * @cost {build-md} 120000
 * @cost {build-lg} 150000
 * @buildings {sm} 2
 * @buildings {md} 4
 * @buildings {lg} 3
 */`
class FrigriGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Frigri", game, guild

  @costs = FrigriGuildHall::costs =
    moveIn: 150000
    build:
      sm: 70000
      md: 120000
      lg: 150000

  baseTile: 7

  startLoc: [1, 11]

  buildings:
    ## Small buildings
    sm: [
      {
        startCoords: [6, 6]
        signpostLoc: [5, 5]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [26, 26]
        signpostLoc: [29, 29]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
    ]

    ## Medium Buildings
    md: [
      {
        startCoords: [15, 5]
        signpostLoc: [20, 4]
        tiles: [
          3, 0, 0, 3, 3
          0, 0, 0, 0, 3,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          3, 0, 0, 0, 3
        ]
      }
      {
        startCoords: [5, 15]
        signpostLoc: [4, 20]
        tiles: [
          3, 0, 0, 0, 3
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          3, 0, 0, 0, 0,
          3, 3, 0, 0, 3
        ]
      }
      {
        startCoords: [25, 15]
        signpostLoc: [24, 14]
        tiles: [
          3, 3, 0, 0, 3
          3, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          3, 0, 0, 0, 3
        ]
      }
      {
        startCoords: [15, 25]
        signpostLoc: [20, 30]
        tiles: [
          3, 0, 0, 0, 3
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 3,
          3, 0, 0, 3, 3
        ]
      }
    ]

    ## Large Buildings
    lg: [
      {
        startCoords: [24, 4]
        signpostLoc: [23, 3]
        tiles: [
          3, 0, 0, 0, 0, 3, 3,
          0, 0, 0, 0, 0, 0, 3,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 3, 0, 0, 0, 0, 3
        ]
      }
      {
        startCoords: [14, 14]
        signpostLoc: [21, 13]
        tiles: [
          3, 3, 0, 0, 0, 3, 3,
          3, 0, 0, 0, 0, 0, 3,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 3,
          3, 3, 0, 0, 0, 3, 3
        ]
      }
      {
        startCoords: [4, 24]
        signpostLoc: [3, 23]
        tiles: [
          3, 0, 0, 0, 0, 3, 3,
          0, 0, 0, 0, 0, 0, 3,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 3, 0, 0, 0, 0, 3
        ]
      }
    ]

module.exports = exports = FrigriGuildHall