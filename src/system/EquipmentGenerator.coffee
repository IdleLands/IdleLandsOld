
_ = require "underscore"
Equipment = require "../item/Equipment"
Generator = require "./Generator"
Chance = require "chance"
chance = new Chance()

class EquipmentGenerator extends Generator
  constructor: (@game) ->

  generateItem: (type = null) ->
    itemList = @game.componentDatabase.itemStats
    type = _.sample @types if not type
    return if not itemList or itemList.length is 0 or not (type of itemList)
    baseItem = _.sample itemList[type]

    item = new Equipment baseItem

    if chance.integer({min: 0, max: 2}) is 1
      @mergePropInto item, _.sample itemList['prefix']
      (@mergePropInto item,  _.sample itemList['prefix']) until chance.integer({min: -1, max: 7**(i = (i+1) or 0)}) isnt 1

    (@mergePropInto item,  _.sample itemList['prefix-special']) if chance.integer({min: 0, max: 21}) is 1

    (@mergePropInto item,  _.sample itemList['suffix']) if chance.integer({min: 0, max: 14}) is 1

    item.type = type

    item.itemClass = @getItemClass item
    @cleanUpItem item

  cleanUpItem: (item) ->
    (if _.isNaN val then item[attr] = true) for attr,val of item
    item

  getItemClass: (item) ->
    itemClass = "basic"
    itemClass = "pro" if item.name.toLowerCase() isnt item.name
    itemClass = "idle" if item.name.toLowerCase().indexOf("idle") isnt -1 or item.name.toLowerCase().indexOf("idling") isnt -1
    itemClass = "godly" if item.score() > 5000

    itemClass

  generateItemAtScore: (targetScore, tolerance = 0.15) ->
    testItem = (item) ->
      baseScore = item.score()
      flux = baseScore * tolerance
      baseScore-flux <= targetScore <= baseScore+flux

    item = @cleanUpItem @generateItem()
    item = @cleanUpItem @generateItem() while not testItem item

    item


module.exports = exports = EquipmentGenerator
