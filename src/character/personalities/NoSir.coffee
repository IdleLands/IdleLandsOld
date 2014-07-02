
Personality = require "../base/Personality"

class NoSir extends Personality
  constructor: ->

  calculateYesPercentBonus: -> -50

module.exports = exports = NoSir