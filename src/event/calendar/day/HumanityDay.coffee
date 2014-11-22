
TimePeriod = require "../../TimePeriod"

`/**
  * The Humanity day increases all stats for players.
  *
  * @name Humanity Day
  * @effect +10% DEX (Only applies to players)
  * @effect +10% STR (Only applies to players)
  * @effect +10% INT (Only applies to players)
  * @effect +10% WIS (Only applies to players)
  * @effect +10% AGI (Only applies to players)
  * @effect +10% CON (Only applies to players)
  * @effect +10% LUCK (Only applies to players)
  * @category Day
  * @package Calendar
*/`
class HumanityDay extends TimePeriod

  constructor: ->
  
  @dateName = "Day of Humanity"
  @desc = "+10% all player stats"

  @dexPercent: (character) -> 10 if character.playerManager
  @strPercent: (character) -> 10 if character.playerManager
  @intPercent: (character) -> 10 if character.playerManager
  @wisPercent: (character) -> 10 if character.playerManager
  @agiPercent: (character) -> 10 if character.playerManager
  @conPercent: (character) -> 10 if character.playerManager
  @luckPercent: (character) -> 10 if character.playerManager

module.exports = exports = HumanityDay