
Event = require "../Event"
_ = require "lodash"
Constants = require "../../system/utilities/Constants"

`/**
 * This event handles both the enchant and tinker aliases, which add new stats to an item.
 *
 * @name Enchant
 * @category Player
 * @package Events
 */`
class EnchantEvent extends Event
  go: ->
    item = @pickValidItem @player, yes

    return if (not item) or (item.name is "empty") or item.enchantLevel >= Constants.defaults.game.maxEnchantLevel

    if @event.type is 'enchant'
      stat = @pickStatNotPresentOnItem item
      boost = 10
    else
      stat = @pickSpecialNotPresentOnItem item
      boost = 1

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    item[stat] = boost

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    string = "#{@event.remark} [<event.enchant.stat>#{stat} = #{boost}</event.enchant.stat> | <event.enchant.boost>+#{item.enchantLevel} -> +#{++item.enchantLevel}</event.enchant.boost>]"

    @game.eventHandler.broadcastEvent {message: string, player: @player, extra: extra, type: 'item-enchant'}

    ##TAG:EVENT_EVENT: tinker | player, item, newEnchantLevel | Emitted when a player has a tinker event happen
    ##TAG:EVENT_EVENT: enchant | player, item, newEnchantLevel | Emitted when a player has an enchant event happen
    @player.emit "event.#{@event.type}", @player, item, item.enchantLevel

module.exports = exports = EnchantEvent
