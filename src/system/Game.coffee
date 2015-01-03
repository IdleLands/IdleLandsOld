
AchievementManager = require "./AchievementManager"
PlayerManager = require "./PlayerManager"
GuildManager = require "./GuildManager"
PetManager = require "./PetManager"
EventHandler = require "./EventHandler"
MonsterGenerator = require "./MonsterGenerator"
MessageCreator = require "./MessageCreator"
ComponentDatabase = require "./ComponentDatabase"
EquipmentGenerator = require "./EquipmentGenerator"
SandwichGenerator = require "./SandwichGenerator"
ShopGenerator = require "./ShopGenerator"
GlobalEventHandler = require "./GlobalEventHandler"
Calendar = require "./Calendar"
BattleManager = require "./BattleManager"
BossFactory = require "../event/BossFactory"
TreasureFactory = require "../event/TreasureFactory"
SpellManager = require "./SpellManager"
Constants = require "./Constants"
GMCommands = require "./GMCommands"
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

if ravenURL
  raven = require "raven"
  client = new raven.Client ravenURL, stackFunction: Error.prepareStackTrace

class Game

  constructor: () ->
    errHandler = @errorHandler = client or {captureMessage: console.error, captureException: console.error}

    process.on 'uncaughtException', (err) ->
      #return if err.code in ['EACCES', 'EADDRINUSE'] #handled elsewhere
      console.error (new Date).toUTCString() + ' uncaughtException:', err.message
      #console.error err.stack
      errHandler.captureException err

    @parties = []
    @_battleParties = []

    defer = q.defer()
    @loading = defer.promise

    @componentDatabase = new ComponentDatabase @
    @gmCommands = new GMCommands @
    @petManager = new PetManager @
    @spellManager = new SpellManager @
    @eventHandler = new EventHandler @
    @playerManager = new PlayerManager @
    @guildManager = new GuildManager @
    @globalEventHandler = new GlobalEventHandler @
    @calendar = new Calendar @
    @equipmentGenerator = new EquipmentGenerator @
    @monsterGenerator = new MonsterGenerator @
    @achievementManager = new AchievementManager @
    @sandwichGenerator = new SandwichGenerator @
    @shopGenerator = new ShopGenerator @
    @bossFactory = new BossFactory @
    @treasureFactory = new TreasureFactory @
    @battleManager = new BattleManager @
    @world = new World()

    defer.resolve()

    require "./REST"

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

  selectRandomNonPartyPlayer: ->
    _.sample (_.reject @playerManager.players, (player) -> player.party)

  createParty: (player = null) ->
    player = @selectRandomNonPartyPlayer() if not player

    players = _.without @playerManager.players, player

    partyAdditionSize = Math.min (players.length / 2), chance.integer({min: 1, max: Constants.defaults.game.maxPartyMembers})
    newPartyPlayers = _.sample (_.reject players, (player) -> player.party), partyAdditionSize

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