
Event = require "../Event"

`/**
 * This event handles the dreaded switcheroo - flipStat - event.
 *
 * @name Switcheroo
 * @category Player
 * @package Events
 */`
class FlipStatEvent extends Event
  go: ->
    item = @pickValidItem @player
    stat = @pickStatPresentOnItem item

    return if not stat or item[stat] is 0

    val = item[stat] ? 0

    extra =
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    start = val
    end = -val

    item[stat] = end

    string = "#{@event.remark} [<event.flip.stat>#{stat}</event.flip.stat> <event.flip.value>#{start} -> #{end}</event.flip.value>]"

    @game.eventHandler.broadcastEvent {message: string, player: @player, extra: extra, type: 'item-switcheroo'}

    ##TAG:EVENT_EVENT: flipStat | player, item, stat, val | Emitted when a player has a switcheroo happen
    @player.emit "event.flipStat", @player, item, stat, val

module.exports = exports = FlipStatEvent