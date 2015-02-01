GuildBase = require "../GuildBase"

class HomletGuildHall extends GuildBase
  constructor: (game, guild) ->
    super "Homlet", game, guild

  @costs = HomletGuildHall::costs =
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
        startCoords: [2, 13]
        signpostLoc: [5, 13]
        tiles: [
          0, 0, 0,
          0, 0, 0,
          0, 0, 0
        ]
      }
      {
        startCoords: [20, 18]
        signpostLoc: [19, 18]
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
        startCoords: [2, 22]
        signpostLoc: [3, 21]
        tiles: [
          17, 17, 0, 17,  17,
          17, 0,  0,  0,  17,
          17, 0,  0,  0,  17,
          17, 0,  0,  0,  17,
          17, 17, 17, 17, 17
        ]
      }
      {
        startCoords: [10, 22]
        signpostLoc: [11, 21]
        tiles: [
          17, 17, 0, 17,  17,
          17, 0,  0,  0,  17,
          17, 0,  0,  0,  17,
          17, 0,  0,  0,  17,
          17, 17, 17, 17, 17
        ]
      }
    ]

    ## Large Buildings
    lg: [
      {
        startCoords: [0, 0]
        signpostLoc: [7, 2]
        tiles: [
          0,  0,  0,  0,  0,  0,  0,
          0,  0,  0,  0,  0,  0,  17,
          0,  0,  0,  0,  0,  0,  17,
          0,  0,  0,  0,  0,  0,  0,
          0,  0,  0,  0,  0,  0,  17,
          0,  0,  0,  0,  0,  0,  17,
          0,  17, 17, 17, 17, 17, 17
        ]
      }
      {
        startCoords: [10, 0]
        signpostLoc: [9, 2]
        tiles: [
          0,  0,  0,  0,  0,  0,  0,
          17, 0,  0,  0,  0,  0,  17,
          17, 0,  0,  0,  0,  0,  17,
          0,  0,  0,  0,  0,  0,  17,
          17, 0,  0,  0,  0,  0,  17,
          17, 0,  0,  0,  0,  0,  17,
          17, 17, 17, 17, 17, 17, 17
        ]
      }
    ]

module.exports = exports = HomletGuildHall