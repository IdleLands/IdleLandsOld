
Region = require "../base/Region"

class NorkosTown extends Region

  constructor: ->
  
  @desc = "Luck boost and cheaper shopping"

  @luck: -> 5
  @shopPercent: -> -10

module.exports = exports = NorkosTown