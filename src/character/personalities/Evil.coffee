
Personality = require "../base/Personality"

class Evil extends Personality
  constructor: ->

  alignment: -> -10

  @canUse = -> yes

  @desc = "No prerequisite"

module.exports = exports = Evil