
config = require "../../../config.json"
useREST = config.useREST

return if not useREST

_ = require "lodash"
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

#app.use (morgan('combined', {stream: fs.createWriteStream "#{__dirname}/../../access.log", flags: 'a'}))

# express config
app.use cors()
app.use compression {threshold: 128}
app.use bodyParser.urlencoded extended: no
app.use bodyParser.json()

_.each (_.values requireDir "./rest-routes"), (router) ->
  app.use "/", router

# init
app.use "/img", express.static __dirname + '/../../../assets/img'

# errarz
app.use (err, req, res, next) ->
#  API.gameInstance.errorHandler.captureException err
  console.error err.message, err.stack
  res.status(500).send
    err: err
    message: err.message
    stack: err.stack

# spin it up
http.createServer(app).listen port
