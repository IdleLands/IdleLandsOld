
_ = require "lodash"

GlobalEvent = require "../GlobalEvent"

`/**
 * This event generates some player parties (or uses existing ones) and does some PvP!
 *
 * @name PvP
 * @category Global
 * @package Events
 * @happensEvery 40 minutes
 */`
class PvPEvent extends GlobalEvent
  go: ->
    @game.componentDatabase.getRandomEvent 'battle', {}, (e, event = {}) =>
      event.player = @game.playerManager.randomPlayer()
      @game.battleManager.startBattle [], event

module.exports = exports = PvPEvent