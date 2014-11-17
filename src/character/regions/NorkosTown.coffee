
Region = require "../base/Region"

class NorkosTown extends Region

  constructor: ->

  @name = "Norkos Town"
  @desc = "Luck boost and cheaper shopping"

  @luck: -> 5
  @shopPercent: -> -10
  @shopMult: -> 1
  @shopSlots: -> 4
  @shopQuality: -> 1

module.exports = exports = NorkosTown