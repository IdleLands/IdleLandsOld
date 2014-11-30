
Event = require "../Event"
_ = require "underscore"

`/**
 * This event handles creating a party for the player.
 *
 * @name party
 * @category Player
 * @package Events
 */`
class PartyEvent extends Event
  go: ->
    return if @player.party or @game.inBattle
    newParty = @game.createParty @player
    return if not newParty?.name

    newPartyPlayers = _.without newParty.players, @player

    extra =
      partyMembers: _.str.toSentence _.pluck newPartyPlayers, 'name'
      partyName: newParty.name

    message = @game.eventHandler.broadcastEvent {message: @event.remark, player: @player, extra: extra, type: 'party'}
    _.each newPartyPlayers, (newMember) => @game.eventHandler.broadcastEvent {message: message, player: newMember, extra: extra, sendMessage: no, type: 'party'}

module.exports = exports = PartyEvent