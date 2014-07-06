
###
  to-hit: roll(-opponent.defense, my.to-hit)
  damage: roll(damage)

  @player.emit "self.attack", player, enemy
  @enemy.emit "self.attacked", player, enemy

  @player.emit "ally.attack", player, enemy, playerTeam <emitted to playerTeam>
  @enemy.emit "ally.attacked", player, enemy, enemyTeam <emitted to enemyTeam>
###

_ = require "underscore"
{EventEmitter} = require "events"
chance = (new require "Chance")()

class Battle extends EventEmitter
  constructor: (@game, @parties) ->
    @startBattle()
    @endBattle()

  startBattle: ->
    @initializePlayers()
    @beginTakingTurns()

  initializePlayers: ->
    playerList = _.reduce @parties, ((prev, party) -> prev.concat party.players), []
    @turnOrder = _.sortBy playerList, (player) -> player.calc.stat 'agi'
                  .reverse()

    _.each @turnOrder, (player) ->
      player.hp.toMaximum()
      player.mp.toMaximum()
      player.special.toMaximum()

  #isAnyPlayerAlive: ->
  #  0 < _.reduce @turnOrder, ((prev, player) -> prev + player.hp.getValue()), 0

  playersAlive: ->
    1 < _.reduce @turnOrder, ((count, player) -> count+(not player.hp.atMin())), 0

  beginTakingTurns: ->
    while @playersAlive()
      @turnPosition = @turnPosition or 0
      @turnPosition++
      @turnPosition = 0 if @turnPosition is @turnOrder.length
      player = @turnOrder[@turnPosition]
      @takeTurn player

  takeTurn: (player) ->
    return if player.hp.atMin()

    if chance.bool {likelihood: 100}
      @doPhysicalAttack player
    else
      console.log 'magic'
      # magical attack

  doPhysicalAttack: (player) ->
    target = _.sample _.reject @turnOrder, ((target) -> player.party is target.party)

    console.log "#{player.name} is attacking #{target.name}."

    dodgeChance = chance.integer {min: (-target.calc.dodge()), max: (player.calc.beatDodge())}

    #TODO maybe add a dodge percent so both conditions have to pass
    #dodge percent would only involve the target and it would probably be a 1-100 roll

    if dodgeChance < 0
      console.log "#{target.name} dodged"
      return

    hitChance = chance.integer {min: (-target.calc.hit()), max: (player.calc.beatHit())}

    if hitChance < 0
      console.log "#{target.name} deflected the attack"
      return

    damage = chance.integer {min: 1, max: player.calc.damage()}

    @takeDamage player, target, damage

  takeDamage: (player, target, damage) ->
    console.log "#{target.name} took #{damage} damage."
    target.hp.sub damage

    if target.hp.atMin()
      console.log "#{target.name} is dead."

  endBattle: ->
    @game.inBattle = false

module.exports = exports = Battle