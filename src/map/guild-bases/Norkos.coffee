GuildBase = require "../GuildBase"

class NorkosGuildHall extends GuildBase
  constructor: (game) ->
    super "Norkos", game

  @costs = NorkosGuildHall::costs =
    moveIn: 50000
    build:
      sm: 30000
      md: 40000
      lg: 50000

  tileRef: [
    7
    3
  ]

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
          1, 1, 0, 1, 1,
          1, 0, 0, 0, 1,
          1, 0, 0, 0, 1,
          1, 0, 0, 0, 1,
          1, 1, 1, 1, 1
        ]
      }
      {
        startCoords: [18, 23]
        signpostLoc: [19, 22]
        tiles: [
          1, 1, 0, 1, 1,
          1, 0, 0, 0, 1,
          1, 0, 0, 0, 1,
          1, 0, 0, 0, 1,
          1, 1, 1, 1, 1
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
          1, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 0,
          1, 1, 1, 0, 1, 1, 0
        ]
      }
      {
        startCoords: [2, 9]
        signpostLoc: [9, 13]
        tiles: [
          1, 1, 1, 1, 1, 1, 1,
          1, 0, 0, 0, 0, 0, 1,
          1, 0, 0, 0, 0, 0, 1,
          1, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 1,
          1, 0, 0, 0, 0, 0, 1,
          1, 1, 1, 1, 1, 1, 1
        ]
      }
    ]

module.exports = exports = NorkosGuildHall