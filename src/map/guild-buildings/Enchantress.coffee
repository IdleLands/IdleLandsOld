
GuildBuilding = require "../GuildBuilding"

`/**
 * The Enchantress allows you to get better enchantments on your items, for a price!
 *
 * @name Enchantress
 * @category Buildings
 * @package Guild
 * @cost {level-up} level*5000
 * @property Name (Any string)
 * @property AttemptEnchant (Yes/No; whether or not to attempt unsafe enchantments)
 * @size {sm}
 */`
class Enchantress extends GuildBuilding

  @size = Enchantress::size = "sm"
  @desc = Enchantress::desc = "Upgrade this magic user to get better enchanting capabilities!"
  @levelupCost = Enchantress::levelupCost = (level) -> level * 5000

  properties: [
    { name: "Name", values: ""}
    { name: "AttemptEnchant", values: ["No", "Yes"]}
  ]

  tiles: [
    0,  0,  0,
    0,  0,  0,
    0,  0,  0
  ]

  constructor: (@game, @guild, @name) ->
    super @game, @guild, @name

    name = @getProperty "Name"

    f =
      name: name or "Enchantress"
      gid: 21
      type: "Guild NPC"
      properties:
        forceEvent: "enchant"
        isGuild: yes

    @tiles = [
      0,  0,  0,
      0,  f,  0,
      0,  0,  0
    ]

module.exports = exports = Enchantress