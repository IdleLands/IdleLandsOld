
Event = require "../Event"
_ = require "lodash"
Constants = require "../../system/Constants"

`/**
 * This event handles creating a party for the player, or recruiting new members as applicable.
 *
 * @name party
 * @category Player
 * @package Events
 */`
class PartyEvent extends Event
  go: ->
    return if @game.inBattle or @player.party?.players.length >= Constants.defaults.game.maxPartyMembers

    # recruit a new member if this event comes up and the party size is small enough
    if @player.party
      newMember = @game.selectRandomNonPartyPlayer()
      return if not newMember
      message = "<player.name>#{@player.getName()}</player.name> recruited <player.name>#{newMember.getName()}</player.name> into <event.partyName>#{@player.partyName}</event.partyName>!"
      messageObj = @game.eventHandler.broadcastEvent {message: message, player: @player, type: 'party'}
      @game.eventHandler.broadcastEvent {message: messageObj, player: newMember, sendMessage: no, type: 'party'}
      @player.party.recruit [newMember]
      @grantRapportForAllPlayers @player.party, 1
      return

    # build a new party
    newParty = @game.createParty @player
    return if not newParty?.name

    newPartyPlayers = _.without newParty.players, @player

    extra =
      partyMembers: _.str.toSentence _.pluck newPartyPlayers, 'name'
      partyName: newParty.name

    message = @game.eventHandler.broadcastEvent {message: @event.remark, player: @player, extra: extra, type: 'party'}
    _.each newPartyPlayers, (newMember) => @game.eventHandler.broadcastEvent {message: message, player: newMember, extra: extra, sendMessage: no, type: 'party'}

    @grantRapportForAllPlayers newParty, 1

module.exports = exports = PartyEvent