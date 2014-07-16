

finder = require "fs-finder"
watch = require "node-watch"
_ = require "underscore"

#### GAME CONSTANTS ####

# change this if you want the console game to go faster
DELAY_INTERVAL = 10

########################

idlePath = __dirname + "/../../src"

players = [
  'Jombocom'
  'Carple'
  'Danret'
  'Goop'
  'Jeut'
  'Axce'
  'Groat'
]

hashes = []
playerHash = {}

## utility functions ##

uniqueId = (playerName) ->
  "local-server/#{playerName}"

buildHashes = ->
  hashes = _.each players, (player) ->
      playerHash[uniqueId player] = player
    .map (player) -> uniqueId player

broadcast = (message) ->
  console.log message

broadcastHandler = (messageArray) ->
  messageArray = [messageArray] if !_.isArray messageArray

  constructMessage = (messageToConstruct) ->
    _.map messageToConstruct, (messageItem) ->
      messageItem.message
    .join ' '

  message = constructMessage messageArray
  broadcast message

## ## ## ## ## ## ## ##

interval = null
IdleWrapper = require(idlePath+"/system/ExternalWrapper")()

## API call functions ##
loadIdle = ->
  IdleWrapper.load()
  IdleWrapper.api.register.broadcastHandler broadcastHandler, null
  do loadAllPlayers

registerAllPlayers = ->
  _.each hashes, (playerHashInList) ->
    IdleWrapper.api.register.player {identifier: playerHashInList, name: playerHash[playerHashInList]}, null

loadAllPlayers = ->
  _.each hashes, (playerHash) ->
    IdleWrapper.api.add.player playerHash

gameLoop = ->
  interval = setInterval =>
    IdleWrapper.api.game.nextAction _.sample hashes
  , DELAY_INTERVAL
## ## ## ## ## ## ## ##

## other functions ##
watchIdleFiles = ->
  loadFunction = _.debounce loadIdle, 100
  watch idlePath, {}, ->
    files = finder.from(idlePath).findFiles "*.coffee"

    _.each files, (file) ->
      delete require.cache[file]

    loadFunction()
#####################

## ## initial load ## ##
do buildHashes
do loadIdle
do registerAllPlayers
do loadAllPlayers
do watchIdleFiles
do gameLoop