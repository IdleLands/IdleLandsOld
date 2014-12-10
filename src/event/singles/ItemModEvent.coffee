
Event = require "../Event"
MessageCreator = require "../../system/MessageCreator"
_ = require "lodash"
Constants = require "../../system/Constants"
chance = new (require "chance")()

`/**
 * This event handles blessing or forsaking items.
 *
 * @name ItemMod
 * @category Player
 * @package Events
 */`
class ItemModEvent extends Event
  go: ->
    item = @pickValidItem @player
    stat = @pickBlessStat item
    return if not stat

    val = item[stat] ? 0

    boost = 0

    if (chance.bool {likelihood: @player.calc.eventFumble()})
      boost = Constants.eventEffects[@event.type].amount
    else
      boost = Math.floor(Math.abs(val)*Constants.eventEffects[@event.type].percent/100)

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    start = val
    end = val+boost

    return if start is end

    item[stat] = end

    string = MessageCreator.doStringReplace @event.remark, @player, extra
    string += " [<event.blessItem.stat>#{stat}</event.blessItem.stat> <event.blessItem.value>#{start} -> #{end}</event.blessItem.value>]"

    @game.eventHandler.broadcastEvent {message: string, player: @player, type: 'item-mod'}
    @player.emit "event.#{@event.type}", @player, item, boost

module.exports = exports = ItemModEvent