
config = require "../../config.json"
useREST = config.useREST

return if not useREST

API = require "./API"

fallbackPort = 3001
port = config.restPort or fallbackPort

express = require "express"
app = express()

bodyParser = require "body-parser"
brute = require "express-brute"
bruteMongo = require "express-brute-mongo"
Mongo = require("mongodb").MongoClient

# express config
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: no

# brute setup
store = new bruteMongo (ready) ->
  Mongo.connect "mongodb://127.0.0.1:27017/brute", (e, db) ->
    ready db.collection "bruteforce-cache"

turnTimeout = new brute store,
  freeRetries: 0
  proxyDepth: 1
  minWait: 10*1000
  maxWait: 10*1000
  attachResetToRequest: no
  refreshTimeoutOnRequest: no
  lifetime: 10
  failCallback: (req, res) -> res.json {isSuccess: no, message: "You can only have one turn every 10 seconds!"}

charCreate = new brute store,
  freeRetries: 0
  proxyDepth: 1
  minWait: 24*60*60*1000
  maxWait: 24*60*60*1000
  attachResetToRequest: no
  refreshTimeoutOnRequest: no
  lifetime: 24*60*60
  failCallback: (req, res) -> res.json {isSuccess: no, message: "You can only create a new character once per day!"}

router = express.Router()

###
  /player

  PUT     /player/auth | ACTION: REGISTER   | REQUEST: {name, identifier, password}   | RETURN: {message, isSuccess, player, token}
  PATCH   /player/auth | ACTION: CHANGEPASS | REQUEST: {identifier, password, token}  | RETURN: {message, isSuccess}
  POST    /player/auth | ACTION: LOGIN      | REQUEST: {identifier, password}         | RETURN: {message, isSuccess, player, token}
  DEL     /player/auth | ACTION: LOGOUT     | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  /player/action

  POST    /player/action/turn         | ACTION: NEWTURN | REQUEST: {identifier, token} | RETURN: {message, isSuccess, player}

  /player/manage

  PUT     /player/manage/inventory    | ACTION: ADD     | REQUEST: {identifier, itemSlot, token}  | RETURN: {message, isSuccess}
  DEL     /player/manage/inventory    | ACTION: SELL    | REQUEST: {identifier, invSlot,  token}  | RETURN: {message, isSuccess}
  PATCH   /player/manage/inventory    | ACTION: SWAP    | REQUEST: {identifier, invSlot,  token}  | RETURN: {message, isSuccess}

  PUT     /player/manage/gender       | ACTION: ADD     | REQUEST: {identifier, gender, token}    | RETURN: {message, isSuccess}
  DEL     /player/manage/gender       | ACTION: REMOVE  | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  PUT     /player/manage/personality  | ACTION: ADD     | REQUEST: {identifier, newPers, token}   | RETURN: {message, isSuccess}
  DEL     /player/manage/personality  | ACTION: REMOVE  | REQUEST: {identifier, oldPers, token}   | RETURN: {message, isSuccess}

  PUT     /player/manage/pushbullet   | ACTION: ADD     | REQUEST: {identifier, apiKey, token}    | RETURN: {message, isSuccess}
  DEL     /player/manage/pushbullet   | ACTION: REMOVE  | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  PUT     /player/manage/string       | ACTION: ADD     | REQUEST: {identifier, type, msg, token} | RETURN: {message, isSuccess}
  DEL     /player/manage/string       | ACTION: REMOVE  | REQUEST: {identifier, type, token}      | RETURN: {message, isSuccess}
###

hasValidToken = (req, res, next) ->
  {identifier, token} = req.body
  API.player.auth.isTokenValid identifier, token
  .then (resp) ->
    if resp.isSuccess
      next()
    else
      res.json {isSuccess: no, message: "Token validation failed."}

router

.route "/player"

# register
.put  (req, res) ->
  API.player.auth.register req.body
  .then (resp) -> res.json resp

# logout
.delete hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.auth.logout identifier
  .then (resp) -> res.json resp

# login
.post (req, res) ->
  {identifier, password} = req.body
  API.player.auth.loginWithPassword identifier, password
  .then (resp) -> res.json resp

# change pass
.patch hasValidToken, (req, res) ->
  {identifier, password} = req.body
  API.player.auth.setPassword identifier, password
  .then (resp) -> res.json resp

router

# take turn
.route "/player/action/turn"
.post turnTimeout.prevent, hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.nextAction identifier
  .then (resp) -> res.json resp

app.use "/", router

process.on 'uncaughtException', (e) ->
  if e.code is 'EACCES'
    console.error "port #{port} is not available, falling back to port #{fallbackPort}"
    app.listen fallbackPort

app.listen port

console.log "REST API started (port #{port})."