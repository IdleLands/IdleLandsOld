
RestrictedNumber = require "restricted-number"

###
  YesMan
  NoSir
  SadSandman
  PokeyPriest
  Random
  Magical
  Physical

  Personality traits should be stackable
###

###
  @health
  @mana
  @speed
  @magic
  @power
  @luck
  @consti

  @emotional
  @spiritual
  @physical
  @magical

###

class Character

  constructor: (options) ->
    [@name, @identifier] = [options.name, options.identifier]
    @hp = new RestrictedNumber 0, 20, 20
    @mp = new RestrictedNumber 0, 0, 0
    @special = new RestrictedNumber 0, 0, 0
    @level = new RestrictedNumber 0, 100, 0

  moveAction: ->

  decisionAction: ->

  combatAction: ->

module.exports = exports = Character