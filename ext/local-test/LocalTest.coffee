
finder = require "fs-finder"
watch = require "node-watch"
_ = require "underscore"

#### GAME CONSTANTS ####

# change this if you want the console game to go faster
DELAY_INTERVAL = 1

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
  'Jack'
  'Xefe'
  'Ooola'
  'Getry'
  'Seripity'
  'Tence'
  'Rawgle'
  'Plez'
  'Zep'
  'Shet'
  'Lord Sirpy'
  'Sir Pipe'
  'Pleb'
  'Rekter'
  'Pilu'
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

genItem = ->
  getWrapper().api.gameInstance.equipmentGenerator.generateItem()

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
  variables = {}

  cli.on 'line', (line) ->
    clearInterval(interval)
    cli.setPrompt "halted: c to continue> "

    if (line) == ""
      cli.prompt()
    else if (line) == "c"
      do gameLoop
    else
      try
      # Replace variables with values from hash
        _.each Object.keys(variables), (variable) ->
          regex = new RegExp "%#{variable}%", 'g'
          line = line.replace regex, variables[variable]

        # Match if user tried to assign a variable
        line.match /%(\w*)%=(.*)/

        # Assign variables to hash table
        if RegExp.$1 and RegExp.$2
          variables[RegExp.$1] = RegExp.$2
          line = RegExp.$2

        broadcast "Evaluating [#{line}]"
        result = eval(line)
        broadcast result
        variables['lc'] = line if result?
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
do IdleWrapper.api.add.allData