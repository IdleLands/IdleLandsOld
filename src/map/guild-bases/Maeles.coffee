GuildBase = require "../GuildBase"

`/**
 * This guild base is located in Maeles.
 *
 * @name Maeles
 * @category Bases
 * @package Guild
 * @cost {move-in} 100000
 * @cost {build-sm} 60000
 * @cost {build-md} 75000
 * @cost {build-lg} 100000
 * @buildings {sm} 3
 * @buildings {md} 2
 * @buildings {lg} 3
 */`
class MaelesGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Maeles", game, guild

  @costs = MaelesGuildHall::costs =
    moveIn: 100000
    build:
      sm: 60000
      md: 75000
      lg: 100000

  baseTile: 7

  startLoc: [10, 16]

  buildings:
    ## Small buildings
    sm: [
      {
        startCoords: [30, 11]
        signpostLoc: [29, 11]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [30, 16]
        signpostLoc: [29, 16]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [30, 21]
        signpostLoc: [29, 21]
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
        startCoords: [5, 3]
        signpostLoc: [6, 8]
        tiles: [
          3, 3, 3, 3, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 0, 0, 0, 3,
          3, 3, 0, 3, 3
        ]
      }
      {
        startCoords: [5, 27]
        signpostLoc: [6, 26]
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
        startCoords: [14, 2]
        signpostLoc: [16, 9]
        tiles: [
          3, 3, 3, 3, 3, 3, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3
          3, 3, 3, 0, 3, 3, 3
        ]
      }
      {
        startCoords: [18, 14]
        signpostLoc: [17, 17]
        tiles: [
          3, 3, 3, 0, 3, 3, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3
          3, 3, 3, 0, 3, 3, 3
        ]
      }
      {
        startCoords: [14, 26]
        signpostLoc: [16, 25]
        tiles: [
          3, 3, 3, 0, 3, 3, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3,
          3, 0, 0, 0, 0, 0, 3
          3, 3, 3, 3, 3, 3, 3
        ]
      }
    ]

module.exports = exports = MaelesGuildHall