GuildBase = require "../GuildBase"

`/**
 * This guild base is located in Raburro, in Norkos -5.
 *
 * @name Raburro
 * @category Bases
 * @package Guild
 * @cost {move-in} 65000
 * @cost {build-sm} 25000
 * @cost {build-md} 45000
 * @cost {build-lg} 65000
 * @buildings {sm} 4
 * @buildings {md} 1
 * @buildings {lg} 2
 */`
class RaburroGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Raburro", game, guild

  @costs = RaburroGuildHall::costs =
    moveIn: 65000
    build:
      sm: 25000
      md: 45000
      lg: 65000

  baseTile: 36

  startLoc: [9, 13]

  buildings:
    ## Small buildings
    sm: [
      {
        startCoords: [2, 2]
        signpostLoc: [5, 2]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [2, 7]
        signpostLoc: [5, 7]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [2, 12]
        signpostLoc: [5, 12]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [2, 17]
        signpostLoc: [5, 17]
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
        startCoords: [7, 2]
        signpostLoc: [7, 4]
        tiles: [
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0
        ]
      }
    ]

    ## Large Buildings
    lg: [
      {
        startCoords: [6, 23]
        signpostLoc: [5, 27]
        tiles: [
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0
        ]
      }
      {
        startCoords: [6, 32]
        signpostLoc: [5, 34]
        tiles: [
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0
        ]
      }
    ]

module.exports = exports = RaburroGuildHall