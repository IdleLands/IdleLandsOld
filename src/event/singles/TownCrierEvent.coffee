
Event = require "../Event"
_ = require "lodash"
Constants = require "../../system/utilities/Constants"
crypto = require "crypto"

`/**
 * This event handles being advertised at.
 *
 * @name Town Crier
 * @category Player
 * @package Events
 */`
class TownCrierEvent extends Event
  go: ->
    @player.emit "event.#{@event.type}", @player, @event
    @game.componentDatabase.lowerAdViewCount @event._id
    @game.eventHandler.broadcastEvent {message: @event.message, player: @player, extra: {link: @event.link, paid: @event.paid, id: "#{@player.name}-#{Date.now()}"}, type: 'towncrier', sendMessage: no, link: @event.link}

module.exports = exports = TownCrierEvent
