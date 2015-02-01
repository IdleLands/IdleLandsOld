GuildBase = require "../GuildBase"

`/**
 * This guild base is located above Vocalnus.
 *
 * @name Vocalnus
 * @category Locations
 * @package Guild Bases
 * @cost {move-in} 25000
 * @cost {build-sm} 15000
 * @cost {build-md} 20000
 * @cost {build-lg} 25000
 * @buildings {sm} 2
 * @buildings {md} 1
 * @buildings {lg} 1
 */`
class VocalnusGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Vocalnus", game, guild

  @costs = VocalnusGuildHall::costs =
    moveIn: 25000
    build:
      sm: 15000
      md: 20000
      lg: 25000

  baseTile: 7

  startLoc: [16, 7]

  buildings:
    ## Small buildings
    sm: [
      {
        startCoords: [22, 8]
        signpostLoc: [21, 8]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [18, 20]
        signpostLoc: [17, 22]
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
        startCoords: [6, 21]
        signpostLoc: [11, 24]
        tiles: [
          50, 0,  50, 50, 50,
          50, 0,  0,  0,  50,
          50, 0,  0,  0,  0,
          0,  0,  0,  0,  50,
          50, 0,  50, 50, 50
        ]
      }
    ]

    ## Large Buildings
    lg: [
      {
        startCoords: [6, 6]
        signpostLoc: [13, 8]
        tiles: [
          50, 50, 50, 0,  50, 50, 50,
          50, 0,  0,  0,  0,  0,  0,
          0,  0,  0,  0,  0,  0,  50,
          50, 0,  0,  0,  0,  0,  0,
          50, 0,  0,  0,  0,  0,  0,
          50, 0,  0,  0,  0,  0,  50,
          0,  50, 50, 50, 0,  50, 50
        ]
      }
    ]

module.exports = exports = VocalnusGuildHall