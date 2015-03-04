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
  getPlayerByName: (name) ->
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

describe "GuildManager", () ->
  describe "Buffs", () ->
    it "Should not be able to add a buff of a person not in a guild", () ->
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
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.addBuff "Oipo", "Agility", "1"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(no)
        expect(res.code).to.equal(59)
        expect(guildManager.guilds.length).to.equal(0)

    it "Should be in a guild / create a guild", () ->
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
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)
        expect(res.code).to.equal(69)
        expect(guildManager.guilds.length).to.equal(1)
        expect(guildManager.guilds[0].name).to.equal("Synology")
        expect(guildManager.guilds[0].leader).to.equal("Oipo")
        expect(player.guild).to.exist()

    it "Should disband a guild", () ->
      NewGuildManager = proxyquire(basedir + 'system/managers/GuildManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
        find: (query, something, callback) ->
        insert: (obj, callback) ->
          callback()
        findForEach: (terms, callback, context = null) ->
        ensureIndex: (fieldOrSpec, options, callback) ->
        update: (query, update, options) ->
        aggregate: (pipeline, options, callback) ->
        remove: (selector, options, callback) ->
      }, '@noCallThru': true )

      player.reset()
      guildManager = new NewGuildManager game
      game.playerManager.db = guildManager.db
      expect(guildManager.guilds.length).to.equal(0)
      promise = guildManager.createGuild "Oipo", "Synology"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)
        expect(guildManager.guilds.length).to.equal(1)
        promise2 = guildManager.disband "Oipo"
        promise2.then (res) ->
          expect(res.isSuccess).to.equal(yes)
          expect(res.code).to.equal(74)
          expect(guildManager.guilds.length).to.equal(0)
          expect(player.guild).to.not.exist()
          expect(player.guildStatus).to.equal(-1)

    it "Should add a buff to guild", () ->
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
          promise = guild.construct "Oipo", "Academy", 0
          promise.then (res) ->
            expect(res.isSuccess).to.equal(yes)
            guild.gold.set 4000
            promise2 = guildManager.addBuff "Oipo", "Agility", "1"
            promise2.then (res) ->
              expect(res.isSuccess).to.equal(yes)
              expect(res.code).to.equal(156)
              expect(guild.buffs).to.exist()
              expect(guild.buffs.length).to.equal(1)

    it "Should add expire a buff", () ->
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
          promise = guild.construct "Oipo", "Academy", 0
          promise.then (res) ->
            expect(res.isSuccess).to.equal(yes)
            guild.gold.set 4000
            promise2 = guildManager.addBuff "Oipo", "Agility", "1"
            promise2.then (res) ->
              expect(res.isSuccess).to.equal(yes)
              guild.buffs[0].expire = 0
              guildManager.checkBuffs()
              expect(guild.buffs.length).to.equal(0)

    it "Should not renew a buff", () ->
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
          promise = guild.construct "Oipo", "Academy", 0
          promise.then (res) ->
            expect(res.isSuccess).to.equal(yes)

            guild.gold.add 4000
            promise = guildManager.addBuff "Oipo", "Agility", "1"
            promise.then (res) ->
              expect(res.isSuccess).to.equal(yes)
              guild.buffs[0].expire = 0
              guild.gold.add 15000
              promise = guild.setProperty "Oipo", "Academy", "AutoRenew", "Yes"
              promise.then (res) ->
                expect(res.isSuccess).to.equal(yes)
                expect(res.code).to.equal(87)
                guild.gold.set 4000
                guildManager.checkBuffs()
                expect(guild.buffs.length).to.equal(0)

    it "Should renew a buff", () ->
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

          promise = guild.construct "Oipo", "Academy", 0
          promise.then (res) ->
            expect(res.isSuccess).to.equal(yes)
            expect(res.code).to.equal(706)

            guild.gold.add 4000

            promise = guildManager.addBuff "Oipo", "Agility", "1"
            promise.then (res) ->
              expect(res.isSuccess).to.equal(yes)

              guild.buffs[0].expire = 0
              guild.gold.add 15000

              promise = guild.setProperty "Oipo", "Academy", "AutoRenew", "Yes"
              promise.then (res) ->
                expect(res.isSuccess).to.equal(yes)
                expect(res.code).to.equal(87)

                guild.gold.add 400000
                guildManager.checkBuffs()
                expect(guild.buffs.length).to.equal(1)

