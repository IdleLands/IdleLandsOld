
_ = require "underscore"

class Spell
  restrictions: {}

  hitPlayer: (player, event = "") ->

  calcDamage: (player) ->

  affect: (affected = [], turns = 0) ->
    affected = [affected] if affected and not _.isArray affected
    if turns is 0
      _.each affected, (player) =>
        @hitPlayer player

    _.each affected, (player) ->
      player.spellsAffectedBy.push @

  unaffect: (player) ->
    player.spellsAffectedBy = _.without player.spellsAffectedBy, @

  constructor: (@game) ->

Spell::Element =
  normal: 1
  ice: 2
  fire: 4
  water: 8
  thunder: 16
  earth: 32

module.exports = exports = Spell