
Event = require "../Event"
Party = require "../Party"

_ = require "lodash"

`/**
 * This event handles building a monster encounter for a player.
 *
 * @name MonsterBattle
 * @category Player
 * @package Events
 */`
class MonsterBattleEvent extends Event
  go: ->
    @event.player = @player
    new Party @game, @player if not @player.party or _.isNaN @player.party
    return if not @player.party

    @game.battleManager.startBattle [@player.party], @event
    @player.emit "event.monsterbattle", @player

module.exports = exports = MonsterBattleEvent