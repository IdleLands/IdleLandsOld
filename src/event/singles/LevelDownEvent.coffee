
Event = require "../Event"
_ = require "underscore"

`/**
 * This event causes players to cry. They also lose a level. This does not occur naturally like most other events, it can only happen by stepping on bad tiles.
 *
 * @name levelDown
 * @category Player
 * @package Events
 */`
class LevelDownEvent extends Event
  go: ->
    currentLevel = @player.level.getValue()
    newLevel = currentLevel - 1

    string = "#{@event.remark} [<player.level>level</player.level> <player.level>#{currentLevel}</player.level> -> <player.level>#{newLevel}</player.level>]"
    @game.eventHandler.broadcastEvent {message: string, player: @player, type: 'levelup'}
    @player.level.sub 1
    @player.emit "event.levelDown", @player, currentLevel, newLevel
    @emit "player.level.down", @player

module.exports = exports = LevelDownEvent