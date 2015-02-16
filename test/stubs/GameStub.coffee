basedir = "../../src/"

sinon = require "sinon"
LogManager = require basedir + "system/managers/LogManager"

module.exports.getGameStub = () ->
  logManager = new LogManager
  game = {}
  game.logManager = logManager

  sinon.stub logManager, "getLogger", (name) ->
    {
    debug: (args...) ->
    info: (args...) ->
    verbose: (args...) ->
    silly: (args...) ->
    }
  game