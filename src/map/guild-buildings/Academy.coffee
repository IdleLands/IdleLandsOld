
GuildBuilding = require "../GuildBuilding"

`/**
 * The Academy affects the capability of your minor permanent buffs as well as the major buffs you can purchase for a limited time.
 *
 * @name Academy
 * @category Buildings
 * @package Guild
 * @cost {level-up} 15000 (if level <= 100)
 * @property AutoRenew (Yes/No; whether or not to auto renew buffs upon expiration)
 * @size {md}
 */`
class Academy extends GuildBuilding

  @size = Academy::size = "md"
  @desc = Academy::desc = "Upgrade this building to make your buffs better and get some permanent ones!"
  @levelupCost = Academy::levelupCost = (level) -> if level > 100 then level * (50000 + (25000*Math.floor level/100)) else 15000
  @getStatEffects: (level) ->
    {
      strPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 1)
        ret = +(ret).toFixed(1)
      intPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 2)
        ret = +(ret).toFixed(1)
      conPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 3)
        ret = +(ret).toFixed(1)
      wisPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 4)
        ret = +(ret).toFixed(1)
      dexPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 5)
        ret = +(ret).toFixed(1)
      agiPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 6)
        ret = +(ret).toFixed(1)
      goldPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 7)
        ret = +(ret).toFixed(1)
      xpPercent: ->
        ret = Math.floor(level/10) * 0.1
        ret += 0.1 if ((level % 10) > 7)
        ret = +(ret).toFixed(1)
      itemFindRange: ->
        ret = Math.floor(level/10) * 100
        ret += 100 if ((level % 10) > 8)
        ret
    }

  properties: [
    { name: "AutoRenew", values: ["No", "Yes"]}
  ]

  f =
    name: "Instructor"
    gid: 12
    type: "Guild NPC"
    properties: {}

  tiles: [
    0,  0,  0,  0,  0,
    0,  f,  0, 44,  0,
    0,  0,  0,  0,  0,
    0,  44, 0, 44,  0,
    0,  0,  0,  0,  0
  ]

module.exports = exports = Academy