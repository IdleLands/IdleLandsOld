
###
  to-hit: roll(-opponent.defense, my.to-hit)
  damage: roll(damage)

  @player.emit "self.attack", player, enemy
  @enemy.emit "self.attacked", player, enemy

  @player.emit "ally.attack", player, enemy, playerTeam <emitted to playerTeam>
  @enemy.emit "ally.attacked", player, enemy, enemyTeam <emitted to enemyTeam>
###
class BattleGroup

class Battle