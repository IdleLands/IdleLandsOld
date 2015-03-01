
_ = require "lodash"

GlobalEvent = require "../GlobalEvent"

`/**
 * This event broadcasts town crier events to a larger audience all at once.
 *
 * @name MassTownCrier
 * @category Global
 * @package Events
 * @happensEvery 60 minutes
 */`
class MassTownCrierEvent extends GlobalEvent
  go: ->
    @game.componentDatabase.getRandomEvent 'towncrier', {blast: 1, expiredOn: {$exists: no}}, (e, event = {}) =>
      return unless event._id

      # Explanation of "6"
      # It is assumed that some players have multiple characters, so we don't want to count duplicates
      # It is assumed that few people watch IRC (and there is no way to know for sure), so we take off a few more
      # This is not broadcast to WebFE, so we have to cut off some players to account for that loss as well
      numPlayers = @game.playerManager.players.length / 6
      @game.componentDatabase.lowerAdViewCount event._id, numPlayers

      linkText = if event.link then "[ #{event.link} ] " else ""
      @game.broadcast ">>> TOWN CRIER: #{linkText}#{event.message}"

module.exports = exports = MassTownCrierEvent