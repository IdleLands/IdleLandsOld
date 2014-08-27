
_ = require "underscore"
Monster = require "../character/npc/Monster"

class MonsterGenerator
  constructor: (@game) ->

  generateMonster: ->
    baseMonster = _.sample @game.componentDatabase.monsters
    monster = new Monster baseMonster

  generateMonsterAtScore: (targetScore, tolerance = 0.15) ->

module.exports = exports = MonsterGenerator