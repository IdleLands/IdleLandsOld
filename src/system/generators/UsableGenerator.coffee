
_ = require "lodash"
Equipment = require "../../item/Equipment"
Usable = require "../../item/Usable"
Generator = require "./Generator"

colorNamer = require "color-namer"

Chance = require "chance"
chance = new Chance()

requireDir = require "require-dir"
allUsables = requireDir "../../item/usables"

class UsableGenerator extends Generator
  constructor: (@game) ->

  generateUsable: (player, bonus = player?.luckBonus() or 0) ->

    baseItem =
      type: "utility"

      _usableProps:
        color: colorNamer(chance.color({format: 'hex'})).ntc[0].name
        type: _.sample UsableGenerator::adjectives
        size: @randomWeightedCharges()

    # 50% chance to be unidentified
    if yes #chance.bool()
      baseItem.unidentified = 1
      baseItem.name = "#{baseItem._usableProps.size} of #{baseItem._usableProps.type}, #{baseItem._usableProps.color} #{_.sample UsableGenerator::liquids}"

    item = new Usable baseItem

    @identify item, player unless item.unidentified

    item

  randomWeightedCharges: ->
    chance.weighted (_.keys UsableGenerator::charges), (_.values UsableGenerator::charges).reverse()

  generateStats: (player) ->

  generateOther: (player) ->

  identify: (item, player) ->
    item.trigger = _.sample _.keys @triggerMults
    item.triggerChance = chance.integer({min: 0, max: 20})*5

    # set proto to the sub item type (allUsables[type].prototype) -- then do that again when loading

    item.score()

UsableGenerator::liquids = [
  "liquid"
  "ooze"
  "sludge"
  "fluid"
  "water"
]

UsableGenerator::types = _.keys allUsables

UsableGenerator::tiers = [
  "garbage"
  "flawed"
  "inferior"
  "lesser"
  "common"
  "plain"
  "standard"
  "uncommon"
  "greater"
  "superior"
  "flawless"
  "glorious"
  "godly"
  "divine"
  "astral"
  "cosmic"
]

UsableGenerator::charges =
  shotglass: 1
  thimble:   3
  vial:      5
  flask:     10
  potion:    15
  jug:       25
  keg:       35
  fountain:  100

UsableGenerator::adjectives = [
  "murky"
  "crystal clear"
  "translucent"
  "swirly"
  "bubbly"
  "smoky"
  "cloudy"
  "effervescent"
  "sparkling"
  "fizzy"
]

# shuffle it every time the game loads. No reason to make it predictable.
UsableGenerator::typeMap = _.zipObject (_.shuffle UsableGenerator::adjectives), (_.shuffle Usable.types)

###

  usable tiers (determines number of stats, what stats are possible):
  * garbage     | 25% restoration,  0.45 multiplier (stat)
  * flawed      | 25% restoration,  0.55 multiplier (stat)
  * inferior    | 25% restoration,  0.65 multiplier (stat)
  * lesser      | 25% restoration,  0.75 multiplier (stat)

  * common      | 50% restoration,  0.85 multiplier (stat)
  * plain       | 50% restoration,  0.95 multiplier (stat)
  * standard    | 50% restoration,  1.05 multiplier (stat)
  * uncommon    | 50% restoration,  1.15 multiplier (stat)

  * greater     | 75% restoration,  1.25 multiplier (stat)
  * superior    | 75% restoration,  1.35 multiplier (stat)
  * flawless    | 75% restoration,  1.45 multiplier (stat)
  * glorious    | 75% restoration,  1.55 multiplier (stat)

  * godly       | 100% restoration, 1.65 multiplier (stat)
  * divine      | 100% restoration, 1.75 multiplier (stat)
  * astral      | 100% restoration, 1.85 multiplier (stat)
  * cosmic      | 100% restoration, 1.95 multiplier (stat)

###

###
  stat mapping:
  * str      -> strength
  * con      -> constitution
  * dex      -> dexterity
  * wis      -> wisdom
  * agi      -> agility
  * int      -> intelligence
  * luck     -> luck

  ^ tier = basic

  * str+con  -> fortitude
  * str+dex  -> force
  * str+wis  -> tactics
  * str+agi  -> offense
  * str+int  -> power
  * str+luck -> celestial strength

  * con+dex  -> defense
  * con+wis  -> revenge
  * con+agi  -> audacity
  * con+int  -> scheming
  * con+luck -> celestial constitution

  * dex+wis  -> acuity
  * dex+agi  -> reflex
  * dex+int  -> prowess
  * dex+luck -> celestial dexterity

  * wis+agi  -> foresight
  * wis+int  -> mystic
  * wis+luck -> celestial wisdom

  * agi+int  -> scrying
  * agi+luck -> celestial agility

  * int+luck -> celestial intelligence

  * all      -> Celestial Dew / Nectar

  ^ tier =
###


module.exports = exports = UsableGenerator
