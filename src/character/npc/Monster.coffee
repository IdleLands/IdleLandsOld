
Character = require "../base/Character"

class Monster extends Character

  constructor: ->
    super()
    @generateBaseEquipment()

  generateBaseEquipment: ->
    @equipment = [
      new Equipment {type: "body",    class: "newbie", name: "Bloody Cloth", con: 1}
      new Equipment {type: "feet",    class: "newbie", name: "Nails of Evil Doom of Evil", dex: 1}
      new Equipment {type: "finger",  class: "newbie", name: "Golden Ring, Fit for Bullying", int: 1}
      new Equipment {type: "hands",   class: "newbie", name: "Fake Infinity Gauntlet Merch", str: 1}
      new Equipment {type: "head",    class: "newbie", name: "Toothy Fangs", wis: 1}
      new Equipment {type: "legs",    class: "newbie", name: "Skull-adorned Legging", agi: 1}
      new Equipment {type: "neck",    class: "newbie", name: "Tribal Necklace", wis: 1, int: 1}
      new Equipment {type: "mainhand",class: "newbie", name: "Large Bloody Bone", str: 1, con: -1}
      new Equipment {type: "offhand", class: "newbie", name: "Chunk of Meat", dex: 1, str: 1}
      new Equipment {type: "charm",   class: "newbie", name: "Human Tooth", con: 1, dex: 1}
    ]