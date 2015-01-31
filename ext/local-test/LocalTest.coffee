
finder = require "fs-finder"
watch = require "node-watch"
colors = require "cli-color"
_ = require "lodash"

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
IdleWrapper = require(idlePath+"/system/accessibility/ExternalWrapper")()

w = getWrapper = -> IdleWrapper

# utility functions for sanity
api = -> w().api
inst = -> api().gameInstance
pm = -> inst().playerManager
petm = -> inst().petManager
player = -> api().player
game = -> api().game
gm = -> api().gm
pname = (name) -> pm().getPlayerByName name
gname = (name) -> inst().guildManager.getGuildByName name
pid = (id) -> pm().getPlayerById id
event = (player, event) -> gm().event.single player, event
gevent = (event) -> gm().event.global event

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
  "event.item.Normal":          colors.whiteBright
  "event.item.basic":           colors.whiteBright
  "event.item.pro":             colors.white
  "event.item.idle":            colors.cyan
  "event.item.godly":           colors.cyanBright
  "event.item.custom":          colors.cyanBright
  "event.item.guardian":        colors.cyan
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
    IdleWrapper.api.gameInstance.loading.then ->
      do loadAllPlayers

  catch e
    console.error e

registerAllPlayers = ->
  _.each hashes, (playerHashInList) ->
    IdleWrapper.api.player.auth.register {identifier: playerHashInList, name: playerHash[playerHashInList]}, null

loadAllPlayers = ->
  _.each hashes, (playerHash) ->
    IdleWrapper.api.player.auth.login playerHash

adjustSpeed = ->
  clearInterval IdleWrapper.api.gameInstance.playerManager.interval
  IdleWrapper.api.gameInstance.playerManager.DELAY_INTERVAL = DELAY_INTERVAL
  IdleWrapper.api.gameInstance.playerManager.beginGameLoop()

gameLoop = ->
  doActionPerMember = (arr, action) ->
    for i in [0...arr.length]
      setTimeout (player, i) ->
        action player
      , DELAY_INTERVAL/arr.length*i, arr[i]

  interval = setInterval ->
    doActionPerMember hashes, IdleWrapper.api.player.takeTurn
  , DELAY_INTERVAL
  
interactiveSession = ->
  readline = require 'readline'

  cli = readline.createInterface process.stdin, process.stdout, null

  cli.on 'line', (line) ->
    clearInterval IdleWrapper.api.gameInstance.playerManager.interval
    clearInterval interval
    cli.setPrompt "halted: c to continue> "

    if line is ""
      cli.prompt()
    else if line is "c"
      do IdleWrapper.api.gameInstance.playerManager.beginGameLoop
      do gameLoop
    else if line is "exit"
      process.exit 0
    else
      try
        broadcast "Evaluating `#{line}`"
        result = eval line
        broadcast result
        result?.then?((res) -> broadcast res.message).done?()
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

    clearInterval IdleWrapper.api.gameInstance.playerManager.interval
    clearInterval interval
    loadFunction()
#####################

## ## initial load ## ##
do buildHashes
do loadIdle

# let the game load before spamming it
inst().loading.then ->
  do registerAllPlayers
  do adjustSpeed
  do gameLoop

do watchIdleFiles
do interactiveSession
