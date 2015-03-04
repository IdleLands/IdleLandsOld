
Event = require "../Event"

`/**
 * This event handles equipping items, finding items, and selling items.
 *
 * @name FindItem
 * @category Player
 * @package Events
 */`
class FindItemEvent extends Event
  go: ->
    item = @game.equipmentGenerator?.generateItem null, @player.calc.luckBonus()
    return if not item

    @game.eventHandler.tryToEquipItem @event, @player, item

module.exports = exports = FindItemEvent