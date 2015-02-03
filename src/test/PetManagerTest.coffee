chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require('proxyquire')
DataStore = require "../system/database/DatabaseWrapper"

expect = chai.expect
describe = mocha.describe

LogManager = require "../system/managers/LogManager"

#stubs
logManager = new LogManager
game = {}
game.logManager = logManager

sinon.stub logManager, "getLogger", (name) ->
  console.log "getLogger " + name
  ""

describe "LogManager", () ->
  describe "getLogger", () ->
    it "Should return empty string", () ->
      #manager = new petManager game
      expect(logManager.getLogger "PetManager").to.equal("")


describe "PetManager", () ->
  describe "constructor", () ->
    it "Should have 0 pets", () ->
      NewPetManager = proxyquire('../system/managers/PetManager', { "./../database/DatabaseWrapper": class DatabaseWrapper
        constructor: (@label, @indexCallback) ->
          console.log "constructor " + @label

        findForEach: (terms, callback, context = null) =>
          console.log "findForEach" + terms
      }, '@noCallThru': true )
      petManager = new NewPetManager game
      expect(petManager.activePets).to.be.empty