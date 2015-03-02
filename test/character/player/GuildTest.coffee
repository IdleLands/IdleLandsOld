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
Academy = require "../../../src/map/guild-buildings/Academy"

#stubs
# WARNING: player object gets modified during tests, so keep track!
player =
{
  identifier: "Oipo"
  gold: new RestrictedNumber 200000, 9999999999, 0
  level: new RestrictedNumber 1, 999999, 9
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

        promise = guild.construct "Oipo", "Academy", 0
        promise.then (res) ->
          expect(res.isSuccess).to.equal(yes)
          expect(res.code).to.equal(706)
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

        promise = guild.construct "Oipo", "Academy", 0
        promise.then (res) ->
          expect(res.isSuccess).to.equal(yes)

          guild.gold = new RestrictedNumber 15000, 9999999999, 0
          promise = guild.upgrade "Oipo", "Academy"
          promise.then (res) ->
            expect(res.isSuccess).to.equal(no)
            expect(res.code).to.equal(81)
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
        guild.gold.add 50000
        guild.buildBase()

        promise = guild.construct "Oipo", "GuildHall", 0
        promise.then (res) ->
          expect(res.isSuccess).to.equal(yes)

          guild.gold.add 50000
          promise = guild.upgrade "Oipo", "GuildHall"
          promise.then (res) ->
            expect(res.isSuccess).to.equal(yes)
            expect(res.code).to.equal(82)
            expect(guild.buildingLevels["GuildHall"]).to.equal(2)

    it "Should calculate bonusses correctly", () ->
      bonusses = Academy.getStatEffects 25
      expect(bonusses.strPercent()).to.equal(0.3)
      expect(bonusses.intPercent()).to.equal(0.3)
      expect(bonusses.conPercent()).to.equal(0.3)
      expect(bonusses.wisPercent()).to.equal(0.3)
      expect(bonusses.dexPercent()).to.equal(0.2)
      expect(bonusses.agiPercent()).to.equal(0.2)
      expect(bonusses.goldPercent()).to.equal(0.2)
      expect(bonusses.xpPercent()).to.equal(0.2)
      expect(bonusses.itemFindRange()).to.equal(200)
