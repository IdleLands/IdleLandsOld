
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
    itemProperties = [baseItem]

    makeItem = (propArray) ->
      propArray = _.uniq propArray
      item = _.reduce propArray, ((combined, prop) ->
        if prop.type is "suffix" then combined.name += " of the #{prop.name}" else combined.name += " #{prop.name}"
        for attr,val of prop
          continue if (not _.isNumber val) or _.isEmpty attr
          if attr of combined then combined[attr] += prop[attr] else combined[attr] = if _.isNaN prop[attr] then true else prop[attr]
        combined
      ), {name: ""}
      item.name = item.name.trim()
      item

    if chance.integer {min: 0, max: 4} is 1
      itemProperties.unshift _.sample itemList['prefix']
      (itemProperties.unshift _.sample itemList['prefix']) until chance.integer({min: 0, max: 7**(i = (i+1) or 0)}) isnt 1

    (itemProperties.unshift _.sample itemList['prefix-special']) if chance.integer({min: 0, max: 21}) is 1

    (itemProperties.push _.sample itemList['suffix']) if chance.integer({min: 0, max: 14}) is 1

    newItem = makeItem itemProperties
    newItem.type = type

    item = new Equipment newItem
    newItem.itemClass = @getItemClass item
    item

  getItemClass: (item) ->
    itemClass = "basic"
    itemClass = "pro" if item.name.toLowerCase() isnt item.name
    itemClass = "idle" if item.name.toLowerCase().indexOf("idle") isnt -1 or item.name.toLowerCase().indexOf("idling") isnt -1
    itemClass = "godly" if item.score() > 5000

    itemClass

module.exports = exports = EquipmentGenerator