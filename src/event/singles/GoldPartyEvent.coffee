
Event = require "../Event"
MessageCreator = require "../../system/handlers/MessageCreator"
_ = require "lodash"

`/**
 * This event handles both the blessGold and forsakeGold aliases for a party.
 *
 * @name Gold
 * @category Party
 * @package Events
 */`
class GoldPartyEvent extends Event
  go: ->
    if not @event.remark
      @game.errorHandler.captureException (new Error "GOLD PARTY EVENT FAILURE"), extra: @event
      return

    return if not @player.party

    extra =
      partyName: @player.party.name

    message = []
    for member in @player.party.players
      boost = @player.calcGoldGain @calcGoldEventGain @event.type, @player

      extra =
        gold: Math.abs boost
        realGold: boost

      member.gainGold boost

      member.emit "event.#{@event.type}", member, extra

      if @event.type is "blessGoldParty"
        message.push "<player.name>#{member.name}</player.name> gained <event.gold>#{Math.abs boost}</event.gold> gold [<event.gold>#{boost}</event.gold> gold]"
      else message.push "<player.name>#{member.name}</player.name> lost <event.gold>#{Math.abs boost}</event.gold> gold [<event.gold>#{boost}</event.gold> gold]"

    extra =
      partyName: @player.party.name

    message = "#{MessageCreator.doStringReplace @event.remark, @player, extra} #{_.str.toSentenceSerial message}."

    @game.eventHandler.broadcastEvent {message: message, player: @player, extra: extra, type: 'gold'}

    for member in @player.party.players
      @game.eventHandler.broadcastEvent {message: message, player: member, extra: extra, sendMessage: no, type: 'gold'} if member isnt @player

    @grantRapportForAllPlayers @player.party, 3

module.exports = exports = GoldPartyEvent