
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
      @game.errorHandler.captureException (new Error "XP EVENT FAILURE"), extra: @event
      return

    boost = @player.calcXpGain @calcXpEventGain @event.type, @player

    rangeManage =
      blessXp:
        f: 'max'
        v: 1
      forsakeXp:
        f: 'min'
        v: -1

    boost = Math[rangeManage[@event.type].f] boost, rangeManage[@event.type].v

    extra =
      xp: Math.abs boost
      realXp: boost
      percentXp: +(boost/@player.xp.maximum*100).toFixed 3

    message = "#{@event.remark} [%realXpxp, ~%percentXp%]"

    @game.eventHandler.broadcastEvent {message: message, player: @player, extra: extra, type: 'exp'}

    @player.gainXp boost

    @player.emit "event.#{@event.type}", @player, extra

module.exports = exports = XpEvent