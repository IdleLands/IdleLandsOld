
_ = require "underscore"
Equipment = require "../item/Equipment"
Chance = require "chance"
chance = new Chance()

class EquipmentGenerator
  types: ['body', 'charm', 'feet', 'finger', 'hands', 'head', 'legs', 'neck', 'mainhand', 'offhand']
  constructor: (@game) ->

  generateItem: ->
    itemList = @game.componentDatabase.itemStats
    type = _.sample @types
    baseItem = _.sample itemList[type]

    item = new Equipment baseItem

    mergePropInto = (baseItem, prop) ->
      if prop.type is "suffix" then baseItem.name += " of the #{prop.name}" else baseItem.name = "#{prop.name} #{baseItem.name}"
      for attr,val of prop
        continue if (not _.isNumber val) or _.isEmpty attr
        if attr of baseItem then baseItem[attr] += prop[attr] else baseItem[attr] = if _.isNaN prop[attr] then true else prop[attr]

      baseItem.name = baseItem.name.trim()

    cleanUpItem = (item) ->
      for attr,val of item
        if _.isNaN val then item[attr] = true
      item

    if chance.integer({min: 0, max: 2}) is 1
      mergePropInto item, _.sample itemList['prefix']
      (mergePropInto item,  _.sample itemList['prefix']) until chance.integer({min: -1, max: 7**(i = (i+1) or 0)}) isnt 1

    (mergePropInto item,  _.sample itemList['prefix-special']) if chance.integer({min: 0, max: 21}) is 1

    (mergePropInto item,  _.sample itemList['suffix']) if chance.integer({min: 0, max: 14}) is 1

    item.type = type

    item.itemClass = @getItemClass item
    item = cleanUpItem item
    item

  getItemClass: (item) ->
    itemClass = "basic"
    itemClass = "pro" if item.name.toLowerCase() isnt item.name
    itemClass = "idle" if item.name.toLowerCase().indexOf("idle") isnt -1 or item.name.toLowerCase().indexOf("idling") isnt -1
    itemClass = "godly" if item.score() > 5000

    itemClass

module.exports = exports = EquipmentGenerator