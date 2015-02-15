basedir = __dirname + "/../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
fs = require "fs"
stream = require "stream"

expect = chai.expect
describe = mocha.describe

LogManager = require basedir + "system/managers/LogManager"

if not fs.existsSync basedir + "../logs"
  fs.mkdirSync basedir + "../logs"

describe "LogManager", () ->
  describe "getLogger", () ->

    it "Should return logger", () ->
      #manager = new petManager game
      logManager = new LogManager
      expect(logManager.getLogger "LogManagerTest").to.exist()

  describe "setLoggerLevel", () ->
    it "Should return success", (done) ->
      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest"
      promise = logManager.setLoggerLevel "LogManagerTest", "verbose"
      promise.then (res) ->
        expect(res.isSuccess).to.equal(yes)
        expect(res.code).to.equal(75)
        expect(res.message).to.equal('Logger level of LogManagerTest set to verbose')
        done()


  describe "logging", () ->
    this.timeout 5000
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
      this.timeout 5000
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


    it "Should clear all files", (done) -> # doesn't work on windows due to EPERM
      this.timeout 500
      if fs.existsSync basedir + "../logs/LogManagerTest3-errors.log"
        fs.unlinkSync basedir + "../logs/LogManagerTest3-errors.log"

      if fs.existsSync basedir + "../logs/LogManagerTest4-errors.log"
        fs.unlinkSync basedir + "../logs/LogManagerTest4-errors.log"

      logManager = new LogManager
      logger = logManager.getLogger "LogManagerTest3"
      logger2 = logManager.getLogger "LogManagerTest4"
      logger.error "testpattern"
      logger2.error "testpattern"
      logger.transports.file.close()
      logger2.transports.file.close()
      logger.close()
      logger2.close()
      setTimeout () ->
        expect(fs.existsSync basedir + "../logs/LogManagerTest3-errors.log").to.equal(yes)
        expect(fs.existsSync basedir + "../logs/LogManagerTest4-errors.log").to.equal(yes)
        contents = fs.readFileSync basedir + "../logs/LogManagerTest3-errors.log", {flag: 'rs'}
        contents2 = fs.readFileSync basedir + "../logs/LogManagerTest4-errors.log", {flag: 'rs'}
        expect(contents.toString()).to.contain('testpattern')
        expect(contents2.toString()).to.contain('testpattern')

        promise = logManager.clearAllLogs()
        promise.then (res) ->
          expect(res.isSuccess).to.equal(yes)
          expect(res.code).to.equal(76)

          files = fs.readdirSync(basedir + "../logs")
          expect(files).to.have.length(0)

          done()
      , 1000