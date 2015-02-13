
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
    @game.componentDatabase.lowerAdViewCount @event._id
    @game.componentDatabase.addPotentialGift @event._id, {player: @player.identifier, id: id}
    @game.eventHandler.broadcastEvent {message: @event.message, player: @player, extra: {link: @event.link, gift: @event.gift, paid: @event.paid, giftId: id, crierId: @event._id}, type: 'towncrier', sendMessage: no, link: @event.link}

    ##TAG:EVENT_EVENT: towncrier | player | Emitted when a player gets their ears attacked by the nearest town crier
    @player.emit "event.towncrier", @player, @event

module.exports = exports = TownCrierEvent
