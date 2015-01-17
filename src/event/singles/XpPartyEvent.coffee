
Event = require "../Event"
MessageCreator = require "../../system/handlers/MessageCreator"
_ = require "lodash"

`/**
 * This event handles both the blessXp and forsakeXp aliases for parties.
 *
 * @name XP
 * @category Party
 * @package Events
 */`
class XpPartyEvent extends Event
  go: ->
    if not @event.remark
      @game.errorHandler.captureException new Error ("XP PARTY EVENT FAILURE"), extra: @event
      return

    return if not @player.party

    message = []
    for member in @player.party.players
      boost = member.calcXpGain @calcXpEventGain @event.type, member
      member.gainXp boost

      percent = boost/member.xp.maximum*100

      extra =
        xp: Math.abs boost
        realXp: boost
        percentXp: +(boost/member.xp.maximum*100).toFixed 3

      member.emit "event.#{@event.type}", member, extra

      if @event.type is "blessXpParty"
        message.push "<player.name>#{member.name}</player.name> gained <event.xp>#{Math.abs boost}</event.xp>xp [~<event.xp>#{+(percent).toFixed 3}</event.xp>%]"
      else message.push "<player.name>#{member.name}</player.name> lost <event.xp>#{Math.abs boost}</event.xp>xp [~<event.xp>#{+(percent).toFixed 3}</event.xp>%]"

    extra =
      partyName: @player.party.name

    message = "#{MessageCreator.doStringReplace @event.remark, @player, extra} #{_.str.toSentenceSerial message}."

    @game.eventHandler.broadcastEvent {message: message, player: @player, extra: extra, type: 'exp'}

    for member in @player.party.players
      @game.eventHandler.broadcastEvent {message: message, player: member, extra: extra, sendMessage: no, type: 'exp'} if member isnt @player

    @grantRapportForAllPlayers @player.party, 3

module.exports = exports = XpPartyEvent