
_ = require "underscore"
Equipment = require "../item/Equipment"
chance = new (require "chance")()

class TreasureFactory
  constructor: (@game) ->

  createTreasure: (chestName, forPlayer) ->

    setAllItemClasses = "idle"

    treasureItems = TreasureInformation.chests[chestName].items

    _.each treasureItems, (item) =>
      baseItem = _.clone TreasureInformation.treasures[item]
      baseItem.name = item
      baseItem.itemClass = setAllItemClasses

      itemInst = new Equipment baseItem

      event = rangeBoost: 1.5, remark: "%player looted %item from the treasure chest \"#{chestName}.\""

      @game.eventHandler.doItemEvent event, forPlayer, itemInst, ->
        forPlayer.emit "event.treasurechest.loot", forPlayer, chestName, item

      forPlayer.emit "event.treasurechest.find", forPlayer, chestName, item

class TreasureInformation
  @timers = {}
  @chests = require "../../config/chests.json"
  @treasures = require "../../config/treasure.json"

module.exports = exports = TreasureFactory
