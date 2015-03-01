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

#stubs
# WARNING: player object gets modified during tests, so keep track!
player =
{
  identifier: "Oipo"
  gold: new RestrictedNumber 200000, 9999999999, 0
  save: () ->
  getExtraDataForREST: (obj1, obj2) ->
    obj2
  reset: () ->
    @guild = null
    @guildStatus = null
    @gold = new RestrictedNumber 200000, 9999999999, 0
}
game = GameStub.getGameStub()
game.playerManager =
{
  getPlayerById: (identifier) ->
    player
}
game.eventHandler =
{
  broadcastEvent: (obj) ->
  addEventToDb: (msg, player, str) ->
}
game.world =
{
  maps: {}
}
game.loading = Q {}

describe "Guild", () ->
  describe "Buildings", () ->
    it "Should create a building", () ->
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

      player.reset()
      guildManager = new NewGuildManager game
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)

        guild = guildManager.guilds[0]
        guild.gold = new RestrictedNumber 40000, 9999999999, 0
        guild.buildBase()

        promise2 = guild.construct "Oipo", "Academy", 0
        promise2.then (res2) ->
          expect(res2.isSuccess).to.equal(yes)
          expect(res2.code).to.equal(706)
          expect(guild.buildingLevels["Academy"]).to.equal(1)


    #no upgraded guildhall
    it "Should not upgrade a building", () ->
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

      player.reset()
      guildManager = new NewGuildManager game
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)

        guild = guildManager.guilds[0]
        guild.gold = new RestrictedNumber 40000, 9999999999, 0
        guild.buildBase()

        promise2 = guild.construct "Oipo", "Academy", 0
        promise2.then (res2) ->
          expect(res2.isSuccess).to.equal(yes)

          guild.gold = new RestrictedNumber 15000, 9999999999, 0
          promise3 = guild.upgrade "Oipo", "Academy"
          promise3.then (res3) ->
            expect(res3.isSuccess).to.equal(no)
            expect(res3.code).to.equal(81)
            expect(guild.buildingLevels["Academy"]).to.equal(1)

    it "Should upgrade a building", () ->
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

      player.reset()
      guildManager = new NewGuildManager game
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)

        guild = guildManager.guilds[0]
        guild.gold = new RestrictedNumber 50000, 9999999999, 0
        guild.buildBase()

        promise2 = guild.construct "Oipo", "GuildHall", 0
        promise2.then (res2) ->
          expect(res2.isSuccess).to.equal(yes)

          guild.gold = new RestrictedNumber 50000, 9999999999, 0
          promise3 = guild.upgrade "Oipo", "GuildHall"
          promise3.then (res3) ->
            expect(res3.isSuccess).to.equal(yes)
            expect(res3.code).to.equal(82)
            expect(guild.buildingLevels["GuildHall"]).to.equal(2)

    it "Should increase str with 0.1%", () ->
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

      player.reset()
      guildManager = new NewGuildManager game
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)

        guild = guildManager.guilds[0]
        guild.gold = new RestrictedNumber 50000, 9999999999, 0
        guild.buildBase()

        promise2 = guild.construct "Oipo", "GuildHall", 0
        promise2.then (res2) ->
          expect(res2.isSuccess).to.equal(yes)

          guild.gold = new RestrictedNumber 50000, 9999999999, 0
          promise3 = guild.upgrade "Oipo", "GuildHall"
          promise3.then (res3) ->
            expect(res3.isSuccess).to.equal(yes)
            expect(res3.code).to.equal(82)
            expect(guild.buildingLevels["GuildHall"]).to.equal(2)