basedir = "../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require "proxyquire"

expect = chai.expect
describe = mocha.describe

GameStub = require "../../stubs/GameStub"
Pet = require basedir + "character/npc/Pet"

#stubs
game = GameStub.getGameStub()

describe "LogManager", () ->
  describe "getLogger", () ->
    it "Should return empty string", () ->
      #manager = new petManager game
      expect(game.logManager.getLogger "PetManager").to.exist()


describe "PetManager", () ->
  describe "constructor", () ->
    it "Should have 0 active pets", () ->
      NewPetManager = proxyquire(basedir + 'system/managers/PetManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
        findForEach: (terms, callback, context = null) ->
      }, '@noCallThru': true )
      petManager = new NewPetManager game
      expect(petManager.activePets).to.be.empty
      expect(petManager.pets).to.be.empty
      expect(petManager.pets).not.to.be.null
      expect(petManager.pets).to.not.be.undefined

    it "Should have 2 active pets", () ->
      NewPetManager = proxyquire(basedir + 'system/managers/PetManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
        findForEach: (terms, callback, context = null) ->
          options =
            name: "testPet"
            attrs: ["1", "2"]
            type: "Pet Rock"

            owner:
              identifier: "testPlayer"
              name: "test"

            creator:
              identifier: "testPlayer"
              name: "test"

          options2 =
            name: "testPet2"
            attrs: ["1", "2"]
            type: "Pet Rock"

            owner:
              identifier: "testPlayer2"
              name: "test2"

            creator:
              identifier: "testPlayer2"
              name: "test2"

          options3 =
            name: "testPet3"
            attrs: ["1", "2"]
            type: "Moose"

            owner:
              identifier: "testPlayer2"
              name: "test2"

            creator:
              identifier: "testPlayer2"
              name: "test2"
          callback.call context, new Pet options
          callback.call context, new Pet options2
          callback.call context, new Pet options3
      }, '@noCallThru': true )

      #constructor
      petManager = new NewPetManager game
      expect(Object.keys(petManager.activePets).length).to.equal(2)
      expect(petManager.activePets).to.have.keys(['testPlayer', 'testPlayer2'])
      expect(petManager.activePets["testPlayer"].type).to.equal("Pet Rock")
      expect(petManager.activePets["testPlayer2"].type).to.equal("Moose")

      #getPetsForPlayer
      petsForTestPlayer = petManager.getPetsForPlayer "testPlayer"
      petsForTestPlayer2 = petManager.getPetsForPlayer "testPlayer2"
      petsForUnknownPlayer = petManager.getPetsForPlayer "blah"
      expect(petsForTestPlayer).to.have.length(1)
      expect(petsForTestPlayer2).to.have.length(2)
      expect(petsForUnknownPlayer).to.have.length(0)
      expect(petsForTestPlayer).to.have.deep.property('[0].name', 'testPet')
      expect(petsForTestPlayer).to.have.deep.property('[0].owner.identifier', 'testPlayer')
      expect(petsForTestPlayer2).to.have.deep.property('[0].name', 'testPet2')
      expect(petsForTestPlayer2).to.have.deep.property('[0].owner.identifier', 'testPlayer2')
      expect(petsForTestPlayer2).to.have.deep.property('[1].name', 'testPet3')
      expect(petsForTestPlayer2).to.have.deep.property('[1].owner.identifier', 'testPlayer2')