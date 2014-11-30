
Event = require "../Event"

`/**
 * This event handles both the blessGold and forsakeGold aliases.
 *
 * @name Gold
 * @category Player
 * @package Events
 */`
class GoldEvent extends Event
  go: ->
    if not @event.remark
      console.error "GOLD EVENT FAILURE", @event
      return

    boost = @player.calcGoldGain @calcGoldEventGain @event.type, @player

    extra =
      gold: Math.abs boost
      realGold: boost

    @player.gainGold boost

    @player.emit "event.#{@event.type}", @player, extra

    message = @event.remark + " [%realGold gold]"

    @broadcastEvent {message: message, player: @player, extra: extra, type: 'gold'}

module.exports = exports = GoldEvent