
AchievementManager = require "./managers/AchievementManager"
PlayerManager = require "./managers/PlayerManager"
GuildManager = require "./managers/GuildManager"
PetManager = require "./managers/PetManager"
EventHandler = require "./handlers/EventHandler"
MonsterGenerator = require "./generators/MonsterGenerator"
MessageCreator = require "./handlers/MessageCreator"
ComponentDatabase = require "./database/ComponentDatabase"
EquipmentGenerator = require "./generators/EquipmentGenerator"
SandwichGenerator = require "./generators/SandwichGenerator"
ShopGenerator = require "./generators/ShopGenerator"
GlobalEventHandler = require "./handlers/GlobalEventHandler"
Calendar = require "./managers/CalendarManager"
BattleManager = require "./managers/BattleManager"
BossFactory = require "../event/BossFactory"
TreasureFactory = require "../event/TreasureFactory"
SpellManager = require "./managers/SpellManager"
Constants = require "./utilities/Constants"
GMCommands = require "./utilities/GMCommands"
Party = require "../event/Party"
Battle = require "../event/Battle"
World = require "../map/World"
q = require "q"

_ = require "lodash"
chance = (new require "chance")()

console.log "Rebooted IdleLands."

config = require "../../config.json"
ravenURL = config.ravenURL

client = null

class LocalCapture
  captureMessage: (others...) ->
    fs = require "fs"
    _.each others, (err) ->
      msg = (JSON.stringify err) + "\r\n" + (err.message ? err) + "\r\n" + (err.stack ? "") + "\r\n\r\n"
      fs.appendFileSync "./err.log", msg
      console.log msg

  captureException: (others...) ->
    fs = require "fs"
    _.each others, (err) ->
      msg = (JSON.stringify err) + "\r\n" + (err.message ? err) + "\r\n" + (err.stack ? "") + "\r\n\r\n"
      fs.appendFileSync "./err.log", msg
      console.log msg

if ravenURL
  raven = require "raven"
  client = new raven.Client ravenURL, stackFunction: Error.prepareStackTrace
else if config.captureLocal
  client = new LocalCapture()

class Game

  constructor: () ->
    errHandler = @errorHandler = client or {captureMessage: console.error, captureException: console.error}

    process.on 'uncaughtException', (err) ->
      return if err.code in ['EADDRINUSE', 'EACCES'] # swallow it
      console.error (new Date).toUTCString() + ' uncaughtException:', err.message
      #console.error err.stack
      errHandler.captureException err

    @parties = []
    @_battleParties = []

    defer = q.defer()
    @loading = defer.promise

    @playerManager = new PlayerManager @
    @guildManager = new GuildManager @
    @petManager = new PetManager @
    @calendar = new Calendar @
    @bossFactory = new BossFactory @
    @battleManager = new BattleManager @
    @componentDatabase = new ComponentDatabase @
    @componentDatabase.loadingAll.then =>
      @gmCommands = new GMCommands @
      @spellManager = new SpellManager @
      @eventHandler = new EventHandler @
      @globalEventHandler = new GlobalEventHandler @
      @equipmentGenerator = new EquipmentGenerator @
      @monsterGenerator = new MonsterGenerator @
      @achievementManager = new AchievementManager @
      @sandwichGenerator = new SandwichGenerator @
      @shopGenerator = new ShopGenerator @
      @treasureFactory = new TreasureFactory @
      @world = new World @

      defer.resolve()

    require "./accessibility/REST"

  registerBroadcastHandler: (@broadcastHandler, @broadcastContext) ->
    console.info "Registered broadcast handler."
    @broadcast "Initializing the Lands that Idle (#{Constants.gameName})."

  registerColors: (colors) ->
    MessageCreator.registerMessageMap colors

  broadcast: (message) ->
    return if not message
    if @broadcastHandler
      (@broadcastHandler.bind @broadcastContext, message)()
    else
      console.error "No broadcast handler registered. Cannot send: #{message}"

  getAllNonPartyPlayers: ->
    _.reject @playerManager.players, (player) -> player.party

  selectRandomNonPartyPlayer: ->
    _.sample @getAllNonPartyPlayers()

  createParty: (player = null) ->
    player = @selectRandomNonPartyPlayer() if not player
    availableGuildies = _.filter @getAllNonPartyPlayers(), (member) -> member isnt player and member.guild is player.guild

    players = _.without @getAllNonPartyPlayers(), player

    partyAdditionSize = Math.min (players.length / 2), chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers})

    playerList = players
    playerList = availableGuildies if partyAdditionSize <= availableGuildies.length and chance.bool({likelihood: 65})

    newPartyPlayers = _.sample playerList, partyAdditionSize

    return if newPartyPlayers.length is 0

    partyPlayers = [player].concat newPartyPlayers

    new Party @, partyPlayers

  arrangeBattle: (teams) ->
    return if teams.length <= 1
    modified = _.flatten teams
    if (_.uniq modified).length < modified.length
      console.error "ERROR: BATTLE FORMATION BLOCKED DUE TO ONE PLAYER BEING DEFINED MULTIPLE TIMES"
      return no

    parties = []
    for team in teams
      playerList = []
      for player in team
        player.party?.playerLeave player, yes
        playerList.push player
      newParty = new Party @, playerList
      parties.push newParty

    @inBattle = true
    new Battle @,parties
    return yes

  teleport: (player, map, x, y, text) ->
    player.map = map
    player.x = x
    player.y = y
    @broadcast MessageCreator.genericMessage text

  doCodeUpdate: ->

    quitCallback = (e, consoleOutput) ->
      console.error "BAD UPDATE",e if e
      console.log consoleOutput
      process.exit 0

    require("git-pull") "#{__dirname}/../", (e, output) =>
      if require("fs").existsSync "#{__dirname}/../../assets/custom"
        console.log output
        @gmCommands.updateCustomData quitCallback
      else
        quitCallback e, output

module.exports = exports = Game