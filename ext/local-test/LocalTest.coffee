
finder = require "fs-finder"
watch = require "node-watch"
colors = require "cli-color"
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

broadcastHandler = (message) ->
  broadcast message

## ## ## ## ## ## ## ##

interval = null
IdleWrapper = require(idlePath+"/system/ExternalWrapper")()

w = getWrapper = -> IdleWrapper

api = -> w().api
inst = -> api().gameInstance
pm = -> inst().playerManager
player = -> api().player
game = -> api().game
gm = -> api().gm

colorMap =
  "player.name":                colors.bold
  "event.partyName":            colors.bold
  "event.partyMembers":         colors.bold
  "event.player":               colors.bold
  "event.damage":               colors.red
  "event.gold":                 colors.yellowBright
  "event.realGold":             colors.yellowBright
  "event.shopGold":             colors.yellowBright
  "event.xp":                   colors.green
  "event.realXp":               colors.green
  "event.percentXp":            colors.green
  "event.item.newbie":          colors.whiteBright
  "event.item.Normal":          colors.black
  "event.item.basic":           colors.black
  "event.item.pro":             colors.white
  "event.item.idle":            colors.cyan
  "event.item.godly":           colors.cyanBright
  "event.item.custom":          colors.cyanBright
  "event.finditem.scoreboost":  colors.bold
  "event.finditem.perceived":   colors.bold
  "event.finditem.real":        colors.bold
  "event.blessItem.stat":       colors.bold
  "event.blessItem.value":      colors.bold
  "event.flip.stat":            colors.bold
  "event.flip.value":           colors.bold
  "event.enchant.boost":        colors.bold
  "event.enchant.stat":         colors.bold
  "event.tinker.boost":         colors.bold
  "event.tinker.stat":          colors.bold
  "event.transfer.destination": colors.bold
  "event.transfer.from":        colors.bold
  "player.class":               colors.bold
  "player.level":               colors.bold
  "stats.hp":                   colors.red
  "stats.mp":                   colors.blue
  "stats.sp":                   colors.yellow
  "damage.hp":                  colors.red
  "damage.mp":                  colors.blue
  "spell.turns":                colors.bold
  "spell.spellName":            colors.bold.underline
  "event.casterName":           colors.bold
  "event.spellName":            colors.bold.underline
  "event.targetName":           colors.bold
  "event.achievement":          colors.bold
  "event.guildName":            colors.bold.underline

## API call functions ##
loadIdle = ->
  try
    IdleWrapper.load()
    IdleWrapper.api.game.handlers.colorMap colorMap
    IdleWrapper.api.game.handlers.broadcastHandler broadcastHandler, null
    do loadAllPlayers
  catch e
    console.error e

registerAllPlayers = ->
  _.each hashes, (playerHashInList) ->
    IdleWrapper.api.player.auth.register {identifier: playerHashInList, name: playerHash[playerHashInList]}, null

loadAllPlayers = ->
  _.each hashes, (playerHash) ->
    IdleWrapper.api.player.auth.login playerHash

gameLoop = ->
  doActionPerMember = (arr, action) ->
    for i in [0...arr.length]
      setTimeout (player, i) ->
        action player
      , DELAY_INTERVAL/arr.length*i, arr[i]
	  
  interval = setInterval =>
    doActionPerMember IdleWrapper.api.player.getAllIdents(), IdleWrapper.api.player.nextAction
  , DELAY_INTERVAL
  
interactiveSession = ->
  readline = require 'readline'

  cli = readline.createInterface process.stdin, process.stdout, null

  cli.on 'line', (line) ->
    clearInterval interval
    cli.setPrompt "halted: c to continue> "

    if line is ""
      cli.prompt()
    else if line is "c"
      do gameLoop
    else
      try
        broadcast "Evaluating `#{line}`"
        result = eval line
        broadcast result
        result?.then? (res) -> broadcast res.message
      catch error
        console.error error.name, error.message, error.stack
      
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
