
config = require "../../config.json"
useREST = config.useREST

return if not useREST

API = require "./API"

fallbackPort = 3001
port = config.restPort or fallbackPort

express = require "express"
app = express()

bodyParser = require "body-parser"
cors = require "cors"

# express config
app.use cors()
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: no

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

  PUT     /player/manage/personality  | ACTION: ADD     | REQUEST: {identifier, newPers, token}   | RETURN: {message, isSuccess}
  DEL     /player/manage/personality  | ACTION: REMOVE  | REQUEST: {identifier, oldPers, token}   | RETURN: {message, isSuccess}

  PUT     /player/manage/pushbullet   | ACTION: ADD     | REQUEST: {identifier, apiKey, token}    | RETURN: {message, isSuccess}
  DEL     /player/manage/pushbullet   | ACTION: REMOVE  | REQUEST: {identifier, token}            | RETURN: {message, isSuccess}

  PUT     /player/manage/string       | ACTION: ADD     | REQUEST: {identifier, type, msg, token} | RETURN: {message, isSuccess}
  DEL     /player/manage/string       | ACTION: REMOVE  | REQUEST: {identifier, type, token}      | RETURN: {message, isSuccess}
###


# init
app.use "/", require "./rest-routes/Authentication"
app.use "/", require "./rest-routes/ManageGender"
app.use "/", require "./rest-routes/ManageInventory"
app.use "/", require "./rest-routes/ManagePersonality"
app.use "/", require "./rest-routes/ManagePushbullet"
app.use "/", require "./rest-routes/TurnAction"

# error catching
process.on 'uncaughtException', (e) ->
  if e.code is 'EACCES'
    console.error "port #{port} is not available, falling back to port #{fallbackPort}"
    app.listen fallbackPort

# spin it up
app.listen port

console.log "REST API started (port #{port})."