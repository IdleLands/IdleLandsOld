class BossFactory
  @createBoss = (name) ->

class BossInformation
  @items =
    "Goblin Lord Shortsword":
      itemClass: "idle"
      type: "mainhand"

  @bosses =
    "Goblin Lord":
      stats:
        'class': 'Monster'
        hp: 3000
      items: [
        "Goblin Lord Shortsword"
      ]

module.exports = exports = BossFactory