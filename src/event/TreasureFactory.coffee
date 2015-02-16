
_ = require "lodash"
Equipment = require "../item/Equipment"
chance = new (require "chance")()

class TreasureFactory
  constructor: (@game) ->

  createTreasure: (chestName, forPlayer) ->

    setAllItemClasses = "guardian"

    treasureItems = TreasureInformation.chests[chestName].items

    _.each treasureItems, (item) =>
      baseItem = _.clone TreasureInformation.treasures[item]
      baseItem.name = item
      baseItem.itemClass = setAllItemClasses

      itemInst = new Equipment baseItem

      event = rangeBoost: 1.5, remark: "%player looted %item from the treasure chest \"#{chestName}.\""

      if @game.eventHandler.tryToEquipItem event, forPlayer, itemInst
        ##TAG:EVENT_EVENT: treasurechest.loot | player, chestName, item | Emitted when a player loots an item from a treasure chest
        forPlayer.emit "event.treasurechest.loot", forPlayer, chestName, item

    ##TAG:EVENT_EVENT: treasurechest.find | player, chestName | Emitted when a player finds a treasure chest
    forPlayer.emit "event.treasurechest.find", forPlayer, chestName

class TreasureInformation
  @timers = {}
  @chests = require "../../config/chests.json"
  @treasures = require "../../config/treasure.json"

module.exports = exports = TreasureFactory
