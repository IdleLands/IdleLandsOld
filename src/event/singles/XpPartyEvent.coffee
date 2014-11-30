
Event = require "../Event"
MessageCreator = require "../../system/MessageCreator"
_ = require "underscore"

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
      console.error "XP PARTY EVENT FAILURE", @event
      return

    message = []
    for member in (@player.party?.players or [@player])
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

    @broadcastEvent {message: message, player: @player, extra: extra, type: 'exp'}

    for member in @player.party.players
      @broadcastEvent {message: message, player: member, extra: extra, sendMessage: no, type: 'exp'} if member isnt @player


module.exports = exports = XpPartyEvent