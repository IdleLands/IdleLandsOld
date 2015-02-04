basedir = __dirname + "/../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
rmdir = require "rimraf"
fs = require "fs"
stream = require('stream')

expect = chai.expect
describe = mocha.describe

LogManager = require basedir + "system/managers/LogManager"

deleteLogs = false

if not fs.existsSync basedir + "../logs"
  deleteLogs = true
  fs.mkdirSync basedir + "../logs"
  fs.chmodSync basedir + "../logs", 0o777

describe "LogManager", () ->
  describe "getLogger", () ->

    it "Should return logger", () ->
      #manager = new petManager game
      logManager = new LogManager
      expect(logManager.getLogger "LogManagerTest").to.exist()

  describe "setLoggerLevel", () ->
    it "Should return success", (done) ->

      mocha.afterEach () ->
        if deleteLogs
          path = basedir + "../logs"
          rmdir path, (err) ->
            console.log err

      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest"
      promise = logManager.setLoggerLevel "LogManagerTest", "verbose"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)
        expect(res.code).to.equal(75)
        expect(res.message).to.equal('Logger level of LogManagerTest set to verbose')
        done()


  describe "logging", () ->
    it "Should write stuff in a file", (done) ->
      if not fs.existsSync basedir + "../logs"
        fs.mkdirSync basedir + "../logs"

      if fs.existsSync basedir + "../logs/LogManagerTest-errors.log"
        fs.unlinkSync basedir + "../logs/LogManagerTest-errors.log"

      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest"
      logger.error "testpattern"
      logger.transports.file.close()
      logger.close()
      setTimeout () ->
        contents = fs.readFileSync basedir + "../logs/LogManagerTest-errors.log", {flag: 'rs'}
        expect(contents.toString()).to.contain('testpattern')
        done()
      , 1000

    it "Should clear a file", (done) ->
      if not fs.existsSync basedir + "../logs"
        fs.mkdirSync basedir + "../logs"
        
      if fs.existsSync basedir + "../logs/LogManagerTest2-errors.log"
        fs.unlinkSync basedir + "../logs/LogManagerTest2-errors.log"

      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest2"
      logger.error "testpattern"
      logger.transports.file.close()
      logger.close()
      setTimeout () ->
        expect(fs.existsSync basedir + "../logs/LogManagerTest2-errors.log").to.equal(yes)
        contents = fs.readFileSync basedir + "../logs/LogManagerTest2-errors.log", {flag: 'rs'}
        expect(contents.toString()).to.contain('testpattern')

        promise = logManager.clearLog "LogManagerTest2"
        promise.then (res) ->
          expect(res.isSuccess).to.equal(yes)
          expect(res.code).to.equal(76)

          contents = fs.readFileSync basedir + "../logs/LogManagerTest2-errors.log", {flag: 'rs'}
          expect(contents.toString()).to.be.empty()

          done()
      , 1000