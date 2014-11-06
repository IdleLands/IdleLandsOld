
TimePeriod = require "../../base/TimePeriod"

class HumanityDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Humanity"
  @desc = "10% boost to player stats"

  @dexPercent: (character) -> 10 if character.playerManager
  @strPercent: (character) -> 10 if character.playerManager
  @intPercent: (character) -> 10 if character.playerManager
  @wisPercent: (character) -> 10 if character.playerManager
  @agiPercent: (character) -> 10 if character.playerManager
  @conPercent: (character) -> 10 if character.playerManager
  @luckPercent: (character) -> 10 if character.playerManager

module.exports = exports = HumanityDay