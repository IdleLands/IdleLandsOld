GuildBase = require "../GuildBase"

`/**
 * This guild base is located in Norkos.
 *
 * @name Norkos
 * @category Bases
 * @package Guild
 * @cost {move-in} 50000
 * @cost {build-sm} 30000
 * @cost {build-md} 40000
 * @cost {build-lg} 50000
 * @buildings {sm} 1
 * @buildings {md} 2
 * @buildings {lg} 2
 */`
class NorkosGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Norkos", game, guild

  @costs = NorkosGuildHall::costs =
    moveIn: 50000
    build:
      sm: 30000
      md: 40000
      lg: 50000

  baseTile: 7

  startLoc: [12, 13]

  buildings:
    ## Small buildings
    sm: [
      {
        startCoords: [15, 11]
        signpostLoc: [18, 12]
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
        startCoords: [9, 23]
        signpostLoc: [12, 22]
        tiles: [
          3, 3, 0, 3, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 3, 3, 3, 3
        ]
      }
      {
        startCoords: [18, 23]
        signpostLoc: [19, 22]
        tiles: [
          3, 3, 0, 3, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 3, 3, 3, 3
        ]
      }
    ]

    ## Large Buildings
    lg: [
      {
        startCoords: [23, 0]
        signpostLoc: [25, 7]
        tiles: [
          0, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 0,
          3, 3, 3, 0, 3, 3, 0
        ]
      }
      {
        startCoords: [2, 9]
        signpostLoc: [9, 13]
        tiles: [
          3, 3, 3, 3, 3, 3, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 0,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3
          3, 3, 3, 3, 3, 3, 3
        ]
      }
    ]

module.exports = exports = NorkosGuildHall