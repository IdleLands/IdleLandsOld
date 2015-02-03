basedir = __dirname + "/../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
fs = require "fs"
stream = require('stream')

expect = chai.expect
describe = mocha.describe

LogManager = require basedir + "system/managers/LogManager"

describe "LogManager", () ->
  describe "getLogger", () ->
    it "Should return logger", () ->
      #manager = new petManager game
      logManager = new LogManager
      expect(logManager.getLogger "LogManagerTest").to.exist()

  describe "setLoggerLevel", () ->
    it "Should return success (will fail)", () ->
      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest"
      ret = logManager.setLoggerLevel "LogManagerTest", "verbose"
      expect(ret.isSuccess).to.equal(yes)
      expect(ret.code).to.equal(75)
      expect(ret.message).to.equal('Logger level of LogManagerTest set to verbose')


  describe "logging", () ->
    it "Should write stuff in a file", (done) ->
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

        ret = logManager.clearLog "LogManagerTest2"
        console.log ret
        console.log ret.code
        expect(ret.isSuccess).to.equal(yes)
        expect(ret.code).to.equal(76)

        contents = fs.readFileSync basedir + "../logs/LogManagerTest2-errors.log", {flag: 'rs'}
        expect(contents.toString()).to.be.empty()

        done()
      , 1000