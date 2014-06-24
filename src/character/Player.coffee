
Character = require "./Character"
RestrictedNumber = require "restricted-number"

class Player extends Character

  gold: 0

  constructor: (player) ->
    super player

  levelUp: ->
    Math.floor 500 + (500 * Math.pow @level, 1.67)

module.exports = exports = Player