
Event = require "../Event"
_ = require "lodash"

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
    return if currentLevel is 1
    newLevel = currentLevel - 1

    string = "#{@event.remark} [<player.level>level</player.level> <player.level>#{currentLevel}</player.level> -> <player.level>#{newLevel}</player.level>]"
    @game.eventHandler.broadcastEvent {message: string, player: @player, type: 'levelup'}
    @player.level.sub 1
    @player.resetMaxXp()

    ##TAG:EVENT_EVENT: levelDown | player, currentLevel, newLevel | Emitted when a player loses a level
    @player.emit "event.levelDown", @player, currentLevel, newLevel

    ##TAG:EVENT_PLAYER: level.down | player, currentLevel, newLevel | Emitted when a player loses a level
    @player.emit "player.level.down", @player, currentLevel, newLevel

module.exports = exports = LevelDownEvent