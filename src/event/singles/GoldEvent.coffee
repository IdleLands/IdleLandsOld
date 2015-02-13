
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
      @game.errorHandler.captureException (new Error "GOLD EVENT FAILURE"), extra: @event
      return

    boost = @player.calcGoldGain @calcGoldEventGain @event.type, @player

    rangeManage =
      blessGold:
        f: 'max'
        v: 1
      forsakeGold:
        f: 'min'
        v: -1

    boost = Math[rangeManage[@event.type].f] boost, rangeManage[@event.type].v

    extra =
      gold: Math.abs boost
      realGold: boost

    @player.gainGold boost

    ##TAG:EVENT_EVENT: blessGold   | player, {gold, realGold} | Emitted when a player gets free money
    ##TAG:EVENT_EVENT: forsakeGold | player, {gold, realGold} | Emitted when a player gets loses money
    @player.emit "event.#{@event.type}", @player, extra

    message = @event.remark + " [%realGold gold]"

    @game.eventHandler.broadcastEvent {message: message, player: @player, extra: extra, type: 'gold'}

module.exports = exports = GoldEvent