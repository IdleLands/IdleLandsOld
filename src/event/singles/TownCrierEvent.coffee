
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
    id = "#{@player.name}-#{Date.now()}"
    @player.emit "event.#{@event.type}", @player, @event
    @game.componentDatabase.lowerAdViewCount @event._id
    @game.componentDatabase.addPotentialGift @event._id, {player: @player.identifier, id: id}
    @game.eventHandler.broadcastEvent {message: @event.message, player: @player, extra: {link: @event.link, gift: @event.gift, paid: @event.paid, giftId: id, crierId: @event._id}, type: 'towncrier', sendMessage: no, link: @event.link}

module.exports = exports = TownCrierEvent
