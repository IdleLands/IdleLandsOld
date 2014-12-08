
config = require "../../config.json"
useREST = config.useREST

return if not useREST

_ = require "underscore"
requireDir = require "require-dir"

API = require "./API"

http = require "http"
fallbackPort = 3001
port = config.restPort or fallbackPort

express = require "express"
app = express()

bodyParser = require "body-parser"
cors = require "cors"
compression = require "compression"
morgan = require "morgan"
fs = require "fs"

accessLogStream = fs.createWriteStream "#{__dirname}/access.log", flags: 'a'
app.use morgan 'combined', stream: accessLogStream

# express config
app.use cors()
app.use compression {threshold: 128}
app.use bodyParser.urlencoded extended: no
app.use bodyParser.json()

###

  /player

  PUT     /player/auth/register             | REQUEST: {name, identifier, password}   | RETURN: {message, isSuccess, player, token}
  PATCH   /player/auth/password             | REQUEST: {identifier, password, token}  | RETURN: {message, isSuccess}
  POST    /player/auth/login                | REQUEST: {identifier, password}         | RETURN: {message, isSuccess, player, token}
  POST    /player/auth/logout               | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  /player/action

  POST    /player/action/turn               | REQUEST: {identifier, token}            | RETURN: {message, isSuccess, player}

  /player/manage

  PUT   /player/manage/gender/set           | REQUEST: {identifier, gender, token}    | RETURN: {message, isSuccess}

  PUT     /player/manage/inventory/add      | REQUEST: {identifier, itemSlot, token}  | RETURN: {message, isSuccess}
  POST    /player/manage/inventory/sell     | REQUEST: {identifier, invSlot,  token}  | RETURN: {message, isSuccess}
  PATCH   /player/manage/inventory/swap     | REQUEST: {identifier, invSlot,  token}  | RETURN: {message, isSuccess}

  POST    /player/manage/shop/buy           | REQUEST: {identifier, invSlot,  token}  | RETURN: {message, isSuccess}

  PUT     /player/manage/personality/add    | REQUEST: {identifier, newPers, token}   | RETURN: {message, isSuccess}
  POST    /player/manage/personality/remove | REQUEST: {identifier, oldPers, token}   | RETURN: {message, isSuccess}

  PUT     /player/manage/pushbullet/set     | REQUEST: {identifier, apiKey, token}    | RETURN: {message, isSuccess}
  POST    /player/manage/pushbullet/remove  | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  PUT     /player/manage/string/set         | REQUEST: {identifier, type, msg, token} | RETURN: {message, isSuccess}
  POST    /player/manage/string/remove      | REQUEST: {identifier, type, token}      | RETURN: {message, isSuccess}
###

_.each (_.values requireDir "./rest-routes"), (router) ->
  app.use "/", router

# init
app.use "/img", express.static __dirname + '/../../assets/img'

# error catching
process.on 'uncaughtException', (e) ->
  if e.code is 'EACCES'
    console.error "port #{port} is not available, falling back to port #{fallbackPort}"
    app.listen fallbackPort

# spin it up
http.createServer(app).listen 80
