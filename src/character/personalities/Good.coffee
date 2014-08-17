
Personality = require "../base/Personality"

class Good extends Personality
  constructor: ->

  alignment: -> 10

  @canUse = -> yes

module.exports = exports = Good