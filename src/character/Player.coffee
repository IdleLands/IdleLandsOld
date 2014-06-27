
Character = require "./Character"
RestrictedNumber = require "restricted-number"
MessageCreator = require "../system/MessageCreator"
_ = require "underscore"
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
      @changeProfession "Generalist"

  handleTile: (tile) ->
    if tile.object?.type is "Trainer"
      @playerManager.game.broadcast MessageCreator.genericMessage "#{@name} has met with the #{tile.object.name} trainer!"

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

      @emit 'walk'
      @emit "on#{tile.terrain}"

    else
      @lastDir = null
      @ignoreDir = dir
      @emit 'hitWall'

    @handleTile tile

  changeProfession: (to) ->
    professionProto = require "./classes/#{to}"
    @profession = new professionProto()
    @professionName = professionProto.name
    @profession.load @
    @playerManager.game.broadcast MessageCreator.genericMessage "#{@name} is now a #{to}!"

  decisionAction: ->

  takeTurn: ->
    @moveAction()
    @save()

  save: ->
    return if not @playerManager
    @playerManager.savePlayer @

  gainXp: (xp) ->
    @xp.set 0 if _.isNaN @xp.__current
    @xp.add xp

    if @xp.atMax()
      @levelUp()

  levelUp: ->
    @playerManager.game.broadcast MessageCreator.genericMessage "#{@name} has attained level #{@level.getValue()}!"
    @level.add 1
    @xp.maximum = @levelUpXpCalc @level.getValue()
    @xp.toMinimum()

  levelUpXpCalc: (level) ->
    Math.floor 100 + (400 * Math.pow level, 1.67)

module.exports = exports = Player