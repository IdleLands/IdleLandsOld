
Region = require "../base/Region"

`/**
 * This region varies based on what you put into it! Typically, it will improve over time.
 *
 * @name Guild Hall
 * @effect Varies
 * @category Norkos
 * @package World Regions
 */`
class GuildHall extends Region

  constructor: ->

  @name = "Guild Hall"
  @desc = "Upgradeable"

  @shopMult: (player) -> Math.max 0.1, 10 - (((player.getGuildBuildingLevel 'GuildShop')/2)*0.1)
  @shopSlots: (player) -> (Math.floor (player.getGuildBuildingLevel 'GuildShop')/10) + 2
  @shopQuality: (player) -> 0.25 + (((player.getGuildBuildingLevel 'GuildShop')/5)*0.25)

module.exports = exports = GuildHall