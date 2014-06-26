
Character = require "./Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../system/MessageCreator"
Chance = require "chance"
chance = new Chance()

class Player extends Character

  gold: 0
  isBusy: false

  constructor: (player) ->
    super player

  initialize: ->
    if not @xp
      @xp = new RestrictedNumber 0, (@levelUpXpCalc 0), 0
      @levelUp()
      @x = 10
      @y = 10
      @map = 'norkos'

  moveAction: ->
    randomDir = -> chance.integer({min: 1, max: 9})
    dir = randomDir()
    dir = randomDir() while dir is @ignoreDir

    dir = if chance.bool({likelihood: 75}) then @lastDir else dir
    newLoc = @num2dir dir, @x, @y

    tile = @playerManager.game.world.maps[@map].getTile newLoc.x,newLoc.y
    if not tile.blocked
      @x = newLoc.x
      @y = newLoc.y
      @lastDir = dir
      @ignoreDir = null
    else
      @lastDir = null
      @ignoreDir = dir

    console.log tile, @x, @y

  decisionAction: ->

  takeTurn: ->
    @moveAction()
    @save()

  save: ->
    return if not @playerManager
    @playerManager.savePlayer @

  levelUp: ->
    @playerManager.game.broadcast MessageCreator.genericMessage "#{@name} has attained level #{@level.getValue()}!"
    @level.add 1
    @xp.maximum = @levelUpXpCalc @level.getValue()

  levelUpXpCalc: (level) ->
    Math.floor 500 + (500 * Math.pow level, 1.67)

module.exports = exports = Player