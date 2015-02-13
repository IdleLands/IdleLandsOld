
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

    return unless @player.party

    rangeManage =
      blessGoldParty:
        f: 'max'
        v: 1
      forsakeGoldParty:
        f: 'min'
        v: -1

    extra =
      partyName: @player.party.name

    message = []
    for member in @player.party.players
      boost = @player.calcGoldGain @calcGoldEventGain @event.type, @player
      boost = Math[rangeManage[@event.type].f] boost, rangeManage[@event.type].v

      extra =
        gold: Math.abs boost
        realGold: boost

      member.gainGold boost

      ##TAG:EVENT_EVENT: blessGoldParty   | player, {gold, realGold} | Emitted when a player gets free money while in a party
      ##TAG:EVENT_EVENT: forsakeGoldParty | player, {gold, realGold} | Emitted when a player gets loses money while in a party
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