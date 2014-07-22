
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

getWrapper = ->
  return IdleWrapper

## API call functions ##
loadIdle = ->
  IdleWrapper.load()
  IdleWrapper.api.add.allData()
  IdleWrapper.api.register.broadcastHandler broadcastHandler, null
  do loadAllPlayers

registerAllPlayers = ->
  _.each hashes, (playerHashInList) ->
    IdleWrapper.api.register.player {identifier: playerHashInList, name: playerHash[playerHashInList]}, null

loadAllPlayers = ->
  _.each hashes, (playerHash) ->
    IdleWrapper.api.add.player playerHash

gameLoop = ->
  doActionPerMember = (arr, action) ->
    for i in [0...arr.length]
      setTimeout (player, i) ->
        action player
      , DELAY_INTERVAL/arr.length*i, arr[i]
	  
  interval = setInterval =>
    doActionPerMember hashes, IdleWrapper.api.game.nextAction
  , DELAY_INTERVAL
  
interactiveSession = ->
  readline = require('readline')

  cli = readline.createInterface process.stdin, process.stdout, null

  lastCommand = null
  cli.on 'line', (line) ->
    clearInterval(interval)
    cli.setPrompt "halt: c to continue> "

    if (line) == ""
      cli.prompt()
    else if (line) == "c"
      do gameLoop
    else
      try
        line = line.replace("%lc%", lastCommand)
        cmd = line.split(" ", 1)
        argsPtr = line.indexOf(" ")
        if (argsPtr != -1)
          args = line.substring(argsPtr + 1);
          broadcast "Evaluating [#{cmd}(#{args})]"
          result = eval.call(cmd[0], args)
        else
          broadcast "Evaluating [#{cmd}]"
          result = eval(cmd[0])
        broadcast result
        lastCommand = cmd[0] if result?
      catch error
        broadcast error
      
      cli.prompt()
  
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
do interactiveSession