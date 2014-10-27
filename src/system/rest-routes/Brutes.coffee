
brute = require "express-brute"
bruteMongo = require "express-brute-mongo"
Mongo = require("mongodb").MongoClient

# brute setup
store = new bruteMongo (ready) ->
  Mongo.connect "mongodb://127.0.0.1:27017/brute", (e, db) ->
    ready db.collection "bruteforce-cache"

TurnTimeoutTimer = new brute store,
  freeRetries: 0
  proxyDepth: 1
  minWait: 10*1000
  maxWait: 10*1000
  attachResetToRequest: no
  refreshTimeoutOnRequest: no
  lifetime: 10
  failCallback: (req, res) -> res.json {isSuccess: no, code: 100, message: "You can only have one turn every 10 seconds!"}

CharCreateTimer = new brute store,
  freeRetries: 0
  proxyDepth: 1
  minWait: 24*60*60*1000
  maxWait: 24*60*60*1000
  attachResetToRequest: yes
  refreshTimeoutOnRequest: no
  lifetime: 24*60*60
  failCallback: (req, res) -> res.json {isSuccess: no, code: 101, message: "You can only create a new character once per day!"}

module.exports = {CharCreateTimer, TurnTimeoutTimer}