
Personality = require "../base/Personality"

class Evil extends Personality
  constructor: ->

  alignment: -> -10

  @canUse = -> yes

module.exports = exports = Evil