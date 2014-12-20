
Personality = require "../base/Personality"
chance = new (require "chance")()
MessageCreator = require "../../system/MessageCreator"

`/**
  * This personality allows you to occasionally revive immediately after dying.
  *
  * @name ConsolationPrize
  * @prerequisite Die 50 times
  * @effect -20% hp
  * @effect +5% revive chance
  * @category Personalities
  * @package Player
*/`
class ConsolationPrize extends Personality

  constructor: (player) ->
    @deathListener = (killer, extra) ->
      if chance.bool({likelihood: 5})
        player = extra.dead
        player.hp.toMaximum()
        #bad, but inheritance for whatever reason isn't working
        player?.playerManager?.game?.broadcast MessageCreator.genericMessage "<event.player>#{player.name}</event.player> suddenly sprang back to life, as if guided by a super awesome consolation prize!"

    player.on 'combat.self.killed', @deathListener

  unbind: (player) ->
    player.off 'combat.self.killed', @deathListener

  hpPercent: -> -20

  @canUse = (player) ->
    player.statistics["combat self killed"] >= 50

  @desc = "Die 50 times"

module.exports = exports = ConsolationPrize