
Event = require "../Event"
MessageCreator = require "../../system/MessageCreator"
_ = require "underscore"
Constants = require "../../system/Constants"
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

    if @player.gold.getValue() < shop.price
      response = MessageCreator.doStringReplace "Unfortunately, %player only has %gold gold, and walked away in disappointment.", @player, extra
      @broadcastEvent {message: "#{string} #{response}", player: @player, type: 'shop'}

    else if score > myScore and (chance.bool likelihood: @player.calc.itemReplaceChancePercent())
      response = MessageCreator.doStringReplace "%player gladly buys %item for %shopGold gold! What a deal!", @player, extra

      score = score.toFixed 1
      myScore = myScore.toFixed 1
      realScore = shop.item.score().toFixed 1
      myRealScore = myItem.score().toFixed 1

      @player.equip shop.item

      realScoreDiff = (realScore-myRealScore).toFixed 1
      perceivedScoreDiff = (score-myScore).toFixed 1
      normalizedRealScore = if realScoreDiff > 0 then "+#{realScoreDiff}" else realScoreDiff
      normalizedPerceivedScore = if perceivedScoreDiff > 0 then "+#{perceivedScoreDiff}" else perceivedScoreDiff

      totalString = "#{string} #{response} [perceived: <event.finditem.perceived>#{myScore} -> #{score} (#{normalizedPerceivedScore})</event.finditem.perceived> | real: <event.finditem.real>#{myRealScore} -> #{realScore} (#{normalizedRealScore})</event.finditem.real>]"
      @broadcastEvent {message: totalString, player: @player, extra: extra, type: 'shop'}
      @player.emit "event.merchant", @player, extra
      @player.gold.sub shop.price

    else
      response = MessageCreator.doStringReplace "However, %player decides that %item is useless and leaves in a huff!", @player, extra
      @broadcastEvent {message: "#{string} #{response}", player: @player, type: 'shop'}

module.exports = exports = MerchantEvent