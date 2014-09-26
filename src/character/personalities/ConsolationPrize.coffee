
Personality = require "../base/Personality"
chance = new (require "chance")()

class ConsolationPrize extends Personality

  constructor: (player) ->
    @deathListener = (killer, extra) ->
      player = extra.dead
      console.log player.name,"DIED"
      player.hp.toMaximum() if chance.bool {likelihood: 100}
      player.playerManager.game.broadcast

    player.on 'combat.self.killed', @deathListener

  unbind: (player) ->
    player.off 'combat.self.killed', @deathListener

  hpPercent: -> -10

  @canUse = (player) ->
    player.statistics["combat self killed"] >= 50

module.exports = exports = ConsolationPrize