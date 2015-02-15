basedir = "../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require "proxyquire"

expect = chai.expect
describe = mocha.describe

class API
  @gameInstance = {
    petManager: {
      pets: {}
      activePets: {}
    },
    playerManager: {
      players: {}
    },
    guildManager: {
      guilds: {}
    },
    world: {
      maps: {}
    },
    componentDatabase: {
      generatorCache: [] #[placeholder: ["an ordinary potato"], deity: ["Zeus"]]
      insertString: (type, string) ->
        API.gameInstance.componentDatabase.generatorCache[type] = [] if not @generatorCache[type]
        API.gameInstance.componentDatabase.generatorCache[type].push string
    }
  }

API.gameInstance.componentDatabase.insertString "placeholder", "an ordinary potato"

describe "MessageCreator", () ->
  messageCreator = proxyquire(basedir + 'system/handlers/MessageCreator', {
  "chance":
    class Chance
      constructor: () ->
  , "./../accessibility/API":
    API
  }, '@noCallThru': true )

  it "Should replace %player", () ->
    str = messageCreator.doStringReplace "%player %player", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("<player.name>Wabber</player.name> <player.name>Wabber</player.name>")

  it "Should replace %pet", () ->
    str = messageCreator.doStringReplace "%pet %pet", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
      playerManager:
        game:
          petManager:
            getActivePetFor: (player) ->
              if player.getName() isnt "Wabber"
                throw new Error "Player #{player.getName()} is not Wabber"
              {
              getName: () ->
                "Dezo"
              }
          guildManager:
            getGuildByName: (guild) ->
              {}
      guild: {}
    }
    expect(str).to.equal("<player.name>Dezo</player.name> <player.name>Dezo</player.name>")

  it "Should replace %guild", () ->
    str = messageCreator.doStringReplace "%guild %guild", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
      playerManager:
        game:
          petManager:
            getActivePetFor: (player) ->
              if player.getName() isnt "Wabber"
                throw new Error "Player #{player.getName()} is not Wabber"
              {
              getName: () ->
                "Dezo"
              }
          guildManager:
            getGuildByName: (guild) ->
              if guild isnt "Styx"
                throw new Error "Guild #{guild} is not Styx"
              {}
      guild: "Styx"
    }
    expect(str).to.equal("<event.guildName>Styx</event.guildName> <event.guildName>Styx</event.guildName>")

  it "Should replace %guildMember", () ->
    str = messageCreator.doStringReplace "%guildMember %guildMember", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
      name: "Wabber"
      playerManager:
        players: ["Wubbaloo"]
        game:
          petManager:
            getActivePetFor: (player) ->
              if player.getName() isnt "Wabber"
                throw new Error "Player #{player.getName()} is not Wabber"
              {
              getName: () ->
                "Dezo"
              }
          guildManager:
            getGuildByName: (guild) ->
              if guild isnt "Styx"
                throw new Error "Guild #{guild} is not Styx"
              {members: [{name: "Wubbaloo"}, {name: "Wabber"}]}
      guild: "Styx"
    }
    expect(str).to.equal("<player.name>Wubbaloo</player.name> <player.name>Wubbaloo</player.name>")

  it "Should replace %hishers", () ->
    str = messageCreator.doStringReplace "%hishers %hishers", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("his his")

    str = messageCreator.doStringReplace "%hishers %hishers", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("hers hers")

    str = messageCreator.doStringReplace "%hishers %hishers", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("theirs theirs")

    str = messageCreator.doStringReplace "%Hishers %Hishers", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("His His")

    str = messageCreator.doStringReplace "%Hishers %Hishers", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Hers Hers")

    str = messageCreator.doStringReplace "%Hishers %Hishers", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Theirs Theirs")

  it "Should replace %hisher", () ->
    str = messageCreator.doStringReplace "%hisher %hisher", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("his his")

    str = messageCreator.doStringReplace "%hisher %hisher", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("her her")

    str = messageCreator.doStringReplace "%hisher %hisher", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("their their")

    str = messageCreator.doStringReplace "%Hisher %Hisher", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("His His")

    str = messageCreator.doStringReplace "%Hisher %Hisher", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Her Her")

    str = messageCreator.doStringReplace "%Hisher %Hisher", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Their Their")

  it "Should replace %himher", () ->
    str = messageCreator.doStringReplace "%himher %himher", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("him him")

    str = messageCreator.doStringReplace "%himher %himher", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("her her")

    str = messageCreator.doStringReplace "%himher %himher", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("them them")

    str = messageCreator.doStringReplace "%Himher %Himher", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Him Him")

    str = messageCreator.doStringReplace "%Himher %Himher", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Her Her")

    str = messageCreator.doStringReplace "%Himher %Himher", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("Them Them")

  it "Should replace %heshe", () ->
    str = messageCreator.doStringReplace "%heshe %heshe", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%she %she", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("he he")
    expect(str).to.equal(str2)

    str = messageCreator.doStringReplace "%heshe %heshe", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%she %she", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("she she")
    expect(str).to.equal(str2)

    str = messageCreator.doStringReplace "%heshe %heshe", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%she %she", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("they they")
    expect(str).to.equal(str2)

    str = messageCreator.doStringReplace "%Heshe %Heshe", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%She %She", {
      getGender: () ->
        "male"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("He He")
    expect(str).to.equal(str2)

    str = messageCreator.doStringReplace "%Heshe %Heshe", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%She %She", {
      getGender: () ->
        "female"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("She She")
    expect(str).to.equal(str2)

    str = messageCreator.doStringReplace "%Heshe %Heshe", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    str2 = messageCreator.doStringReplace "%She %She", {
      getGender: () ->
        "Android"
      getName: () ->
        "Wabber"
    }
    expect(str).to.equal("They They")
    expect(str).to.equal(str2)