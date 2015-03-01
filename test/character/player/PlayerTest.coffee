basedir = "../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require "proxyquire"
RestrictedNumber = require "restricted-number"
Q = require "q"

expect = chai.expect
describe = mocha.describe

GameStub = require "../../stubs/GameStub"
Player = require basedir + "character/player/Player"
Calendar = require basedir + "system/managers/CalendarManager"

#stubs
# WARNING: player object gets modified during tests, so keep track!
player = null
game = GameStub.getGameStub()
game.playerManager =
{
  getPlayerById: (identifier) ->
    player
  game: game
  addForAnalytics: () ->
  savePlayer: () ->
  buildPlayerSaveObject: () ->
}
game.eventHandler =
{
  broadcastEvent: (obj) ->
  addEventToDb: (msg, plyr, str) ->
}
game.world =
{
  maps: {
    "Norkos": {
      getTile: (x, y) ->
        {
          region: 'Wilderness'
        }
    }
  }
}
game.loading = Q {}
game.calendar = new Calendar game

describe "Player", () ->
  describe "PersonalityReduce", () ->
    it "Should have guild affecting factors", () ->

      NewGuildManager = proxyquire(basedir + 'system/managers/GuildManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
        find: (query, something, callback) ->
        insert: (obj, callback) ->
          callback()
        findForEach: (terms, callback, context = null) ->
        ensureIndex: (fieldOrSpec, options, callback) ->
        update: (query, update, options) ->
        aggregate: (pipeline, options, callback) ->
      }, '@noCallThru': true )

      guildManager = new NewGuildManager game
      game.guildManager = guildManager
      game.playerManager.db = guildManager.db
      player = new Player {name: "Oipo", identifier: "test#Oipo"}
      player.playerManager = game.playerManager
      player.initialize()
      player.gold.add 100000
      originalVal = player.calc.stat "str"

      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)
        guildManager.guilds[0].buildingLevels["Academy"] = 10000
        #See #702
        expect(player.calc.stat "str").to.be.within(originalVal*2 - 1, originalVal*2)

