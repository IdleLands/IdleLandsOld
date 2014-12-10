
_ = require "lodash"

class BattleCache

  constructor: (@game, teams) ->

    @started = new Date()
    @name = @game.componentDatabase.generateBattleName()
    @parseMembers teams
    @messages = []

  parseMembers: (teams) ->
    @teams = _.map teams, (team) ->
      name: team.name
      members: _.map team.players, (member) -> {name: member.name, level: member.level.getValue(), profession: member.professionName, isPlayer: !!member.playerManager}

  addMessage: (message) ->
    @messages.push message

  finalize: (callback) ->
    @game.componentDatabase.insertBattle (_.omit @, "game"), callback

module.exports = exports = BattleCache