
Event = require "../Event"
MessageCreator = require "../../system/MessageCreator"
_ = require "underscore"

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
      console.error "GOLD PARTY EVENT FAILURE", @event
      return

    extra =
      partyName: @player.party.name

    message = []
    for member in (@player.party?.players or [@player])
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

module.exports = exports = GoldPartyEvent