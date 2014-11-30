
Event = require "../Event"

`/**
 * This event handles both the blessXp and forsakeXp aliases.
 *
 * @name XP
 * @category Player
 * @package Events
 */`
class XpEvent extends Event
  go: ->
    if not @event.remark
      console.error "XP EVENT FAILURE", @event
      return

    boost = @player.calcXpGain @calcXpEventGain @event.type, @player

    extra =
      xp: Math.abs boost
      realXp: boost
      percentXp: +(boost/@player.xp.maximum*100).toFixed 3

    message = "#{@event.remark} [%realXpxp, ~%percentXp%]"

    @broadcastEvent {message: message, player: @player, extra: extra, type: 'exp'}

    @player.gainXp boost

    @player.emit "event.#{@event.type}", @player, extra

module.exports = exports = XpEvent