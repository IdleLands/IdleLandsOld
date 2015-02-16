basedir = "../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require "proxyquire"

expect = chai.expect
describe = mocha.describe

GameStub = require "../../stubs/GameStub"
game = GameStub.getGameStub()


describe "PlayerManager", () ->
  describe "constructor", () ->
    it "Should have 0 players", () ->
      NewPlayerManager = proxyquire(basedir + 'system/managers/PlayerManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
        findForEach: (terms, callback, context = null) ->
        ensureIndex: (fieldOrSpec, options, callback) ->
        update: (query, update, options) ->
      }, '@noCallThru': true )

      playerManager = new NewPlayerManager game
      expect(playerManager.players.length).to.equal(0)