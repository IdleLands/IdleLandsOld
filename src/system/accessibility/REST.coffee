
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
serveIndex = require "serve-index"

#app.use (morgan('combined', {stream: fs.createWriteStream "#{__dirname}/../../access.log", flags: 'a'}))

# express config
app.use cors()
app.use compression {threshold: 128}
app.use bodyParser.urlencoded extended: no
app.use bodyParser.json()

_.each (_.values requireDir "./rest-routes"), (router) ->
  app.use "/", router

# init
## TAG:APIROUTE: GET | /img/tiles.png | {} | IdleLands Tileset
app.use "/img", express.static __dirname + '/../../../assets/img'

# log dir
app.use "/logs", express.static __dirname + '/../../../logs'
app.use "/logs", serveIndex __dirname + '/../../../logs', icons: yes

if config.ravenURL
  raven = require "raven"
  app.error raven.middleware.express config.ravenURL

## errarz
#app.use (err, req, res, next) ->
##  API.gameInstance.errorHandler.captureException err
#  console.error err.message, err.stack
#  res.status(500).send
#    err: err
#    message: err.message
#    stack: err.stack

# spin it up
http.createServer(app).listen port

console.log "REST API started on port #{port}."