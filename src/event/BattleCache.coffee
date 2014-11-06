
_ = require "underscore"

class BattleCache

  constructor: (@game, teams) ->

    @started = new Date()
    @name = @game.componentDatabase.generateBattleName()
    @parseMembers teams
    @messages = []

  parseMembers: (teams) ->
    @teams = _.map teams, (team) ->
      name: team.name
      members: _.map team.players, (member) -> {name: member.name, level: member.level.getValue(), profession: member.professionName}

  addMessage: (message) ->
    @messages.push message

  finalize: ->
    @game.componentDatabase.insertBattle (_.omit @, "game")

module.exports = exports = BattleCache