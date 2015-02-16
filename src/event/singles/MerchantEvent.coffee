
Event = require "../Event"
MessageCreator = require "../../system/handlers/MessageCreator"
_ = require "lodash"
Constants = require "../../system/utilities/Constants"
chance = new (require "chance")()

`/**
 * This event handles purchasing an item for the player from a wandering merchant.
 *
 * @name merchant
 * @category Player
 * @package Events
 */`
class MerchantEvent extends Event
  go: ->
    shop = @game.shopGenerator.generateShop @player
    extra =
      item: "<event.item.#{shop.item.itemClass}>#{shop.item.getName()}</event.item.#{shop.item.itemClass}>"
      gold: @player.gold.getValue()
      shopGold: shop.price

    string = MessageCreator.doStringReplace @event.remark, @player, extra

    myItem = _.findWhere @player.equipment, {type: shop.item.type}
    return if not myItem

    score = @player.calc.itemScore shop.item
    myScore = @player.calc.itemScore myItem

    affirmativeResponse = MessageCreator.doStringReplace "%player gladly buys %item for %shopGold gold! What a deal!", @player, extra
    affirmativeResponseEvent = remark: "#{string} #{affirmativeResponse}", rangeBoost: 1.2, _type: 'shop'

    if @player.gold.getValue() < shop.price
      response = MessageCreator.doStringReplace "Unfortunately, %player only has %gold gold, and walked away in disappointment.", @player, extra
      @game.eventHandler.broadcastEvent {message: "#{string} #{response}", player: @player, type: 'shop'}

    else if score > myScore and (chance.bool likelihood: @player.calc.itemReplaceChancePercent()) and @game.eventHandler.tryToEquipItem affirmativeResponseEvent, @player, shop.item
      ##TAG:EVENT_EVENT: merchant | player, {item, gold, shopGold} | Emitted when a player buys an item from a shop
      @player.emit "event.merchant", @player, extra
      @player.gold.sub shop.price

    else
      response = MessageCreator.doStringReplace "However, %player decides that %item is useless and leaves in a huff!", @player, extra
      @game.eventHandler.broadcastEvent {message: "#{string} #{response}", player: @player, type: 'shop'}

module.exports = exports = MerchantEvent