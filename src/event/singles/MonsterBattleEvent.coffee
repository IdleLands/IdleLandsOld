
Event = require "../Event"
Party = require "../Party"

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

    new Party @game, @player if not @player.party
    party = @player.party
    return if not @player.party

    monsterParty = @game.monsterGenerator.generateMonsterParty party.score()
    return if not monsterParty or monsterParty.players.length is 0

    @game.startBattle [monsterParty, @player.party], @event
    @player.emit "event.monsterbattle", @player

module.exports = exports = MonsterBattleEvent