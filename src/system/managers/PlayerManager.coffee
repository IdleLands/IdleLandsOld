
Datastore = require "./../database/DatabaseWrapper"
_ = require "lodash"
Player = require "../../character/player/Player"
Equipment = require "../../item/Equipment"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./../handlers/MessageCreator"
Constants = require "./../utilities/Constants"
bcrypt = require "bcrypt"
crypto = require "crypto"
LogManager = require "./LogManager"
convenienceFunctions = require "../../system/utilities/ConvenienceFunctions"

class PlayerManager

  players: []
  playerHash: {}

  constructor: (@game) ->
    @db = new Datastore "players", (db) ->
      db.ensureIndex { identifier: 1 }, { unique: true }, ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

      db.update {}, {$set:{isOnline: no}}, {multi: yes}, (e) -> console.error "PLAYER SETINACTIVE ERROR",e.stack if e

    if @game and @game.logManager
      @logManager = @game.logManager
    else
      @logManager = new LogManager()
      @logManager.getLogger("PlayerManager").warn "@game.logManager not set, using isolated LogManager instance, not able to set logger level via !idle-setloggerlevel"

    @interval = null
    @DELAY_INTERVAL = 10000
    @beginGameLoop()

  beginGameLoop: ->

    @interval = setInterval =>
      return if @players.length is 0
      _.each @players, (player, i) =>
        delay = (@DELAY_INTERVAL/@players.length*i) + if i%2 is 1 then @DELAY_INTERVAL/2 else 0
        setTimeout (player, i) ->
          player.takeTurn()
        , delay, player
    , @DELAY_INTERVAL

  randomPlayer: ->
    _.sample @players

  banPlayer: (name, callback) ->
    @db.update {name: name}, {banned: true}, {}, callback

  unbanPlayer: (name, callback) ->
    @db.update {name: name}, {banned: false}, {}, callback

  retrievePlayer: (identifier, callback) ->
    @db.findOne {identifier: identifier}, (e, player) =>
      console.error "BAD FINDING PLAYER #{identifier}",e,e.stack if e
      if not player or player.banned or (_.findWhere @players, {identifier: identifier})
        callback?()
        return

      player = @migratePlayer player
      player.playerManager = @
      callback player

  hashPassword: (password, callback) ->
    bcrypt.genSalt 10, (e, salt) ->
      bcrypt.hash password, salt, callback

  storePasswordForHash: (password, player, defer) ->
    logger = @logManager.getLogger "bcrypt"
    @hashPassword password, (e, hash) ->
      if e
        logger.error "error with bcrypt!", {e}
        defer.resolve {isSuccess: no, code: 9999, message: "Something went wrong. ¯\_(ツ)_/¯"}
      else
        player.password = hash
        logger.info "Success with set storePasswordFor!"
        defer.resolve {isSuccess: yes, code: 17, message: "Your password has been set! Extraneous spaces at be beginning and end have been removed!"}

  storePasswordFor: (identifier, password) ->
    try
      password = password.trim()

      return Q {isSuccess: no, code: 1, message: "Please use a password >= 3 characters."} if password.length < 3

      player = @playerHash[identifier]

      defer = Q.defer()

      if not player
        @db.findOne {identifier: identifier}, (e, player) =>
          if e
            logger = @logManager.getLogger "bcrypt"
            logger.error "error with db.findOne!", {e}
            @game.errorHandler.captureException e, extra: identifier: identifier if e

          defer.resolve {isSuccess: no, code: 10, message: "You're not logged in!"} if not player

          @storePasswordForHash password, player, defer
      else
        @storePasswordForHash password, player, defer

      return defer.promise
    catch e
      logger = @logManager.getLogger "bcrypt"
      logger.error "error with storePasswordFor!", {e}
      Q {isSuccess: no, code: 14, message: "Authentication failure (bad password)."}

  checkToken: (identifier, token) ->

    player = @playerHash[identifier]

    return Q {isSuccess: no, code: 10, message: "You're not logged in!"} if not player
    return Q {isSuccess: no, code: -1, message: "That token isn't valid!"} if player?.tempSecureToken isnt token

    Q {isSuccess: yes, code: 999999, message: "Valid token. Carry on."} #lol

  checkPassword: (identifier, password, isIRC = no) ->

    defer = Q.defer()

    try
      return Q {isSuccess: no, code: 12, message: "You're not currently logged in, so you can't auth via password."} if isIRC and not @playerHash[identifier]
      return Q {isSuccess: no, code: 16, message: "You can't login without a password, silly!"} if not password

      logger = @logManager.getLogger "bcrypt"
      @db.findOne {identifier: identifier}, (e, player) =>
        if e
          logger.error "error with db.findOne!", {e}
        @game.errorHandler.captureException e, extra: identifier: identifier if e

        return defer.resolve {isSuccess: no, code: 13, message: "Authentication failure (player doesn't exist)."} if not player
        return defer.resolve {isSuccess: no, code: 12, message: "You haven't set up a password yet!"} if not player?.password

        bcrypt.compare password, player.password, (e, res) ->
          if not res
            logger.error "error with bcrypt!", {e}
            defer.resolve {isSuccess: no, code: 14, message: "Authentication failure (bad password)."}
          else
            defer.resolve {isSuccess: yes, code: 999999, message: "Successful login. Welcome back!"} #lol

      defer.promise
    catch e
      logger = @logManager.getLogger "bcrypt"
      logger.error "error with checkPassword!", {e}
      Q {isSuccess: no, code: 14, message: "Authentication failure (bad password)."}

  generateTempToken: ->
    crypto.randomBytes 48
      .toString 'hex'

  addPlayer: (identifier, suppress = no, autoLogout = yes) ->
    defer = Q.defer()

    return Q {isSuccess: no, code: 15, message: "Player already logged in."} if @playerHash[identifier]

    @retrievePlayer identifier, (player) =>
      return defer.resolve {isSuccess: no, code: 13, message: "Player not found."} if not player

      player.isOnline = yes
      @players.push player
      @playerHash[identifier] = player
      @game.broadcast "#{player.getName()}, the level #{player.level.__current} #{player.professionName}, has joined #{Constants.gameName}!" if not suppress

      @players = _.uniq @players
      player.tempSecureToken = @generateTempToken()

      player.cannotBeLoggedOut = not autoLogout
      @handleAutoLogout player

      results =
        isSuccess: yes
        code: 18
        message: "Successful login. Welcome back to #{Constants.gameName}, #{player.getName()}!"
        token: player.tempSecureToken

      defer.resolve player.getExtraDataForREST {player: yes, pet: yes, pets: yes, guild: yes, guildInvites: yes, global: yes}, results

    defer.promise

  removePlayer: (identifier) ->

    player = @playerHash[identifier]
    return Q {isSuccess: no, code: 13, message: "Player not found."} if not player

    player.isOnline = no
    player.tempSecureToken = null
    player.party?.playerLeave player, yes
    @savePlayer player

    name = player.name

    @players = _.reject @players, (player) -> player.identifier is identifier
    delete @playerHash[identifier]
    @playerHash[identifier] = null

    @game.broadcast "#{name} has left #{Constants.gameName}!"
    Q {isSuccess: yes, code: 19, message: "Player successfully logged out."}

  loginWithPassword: (identifier, password) ->

    defer = Q.defer()

    @checkPassword identifier, password
    .then (res) =>

      return defer.resolve res if not res.isSuccess

      baseResults =
        isSuccess: yes
        code: 15

      if @playerHash[identifier]
        player = @playerHash[identifier]
        realResults = player.getExtraDataForREST {player: yes, pet: yes, pets: yes, guildInvites: yes, guild: yes, global: yes}, baseResults
        realResults.token = player.tempSecureToken
        realResults.message = "This is a duplicate login session."
        return defer.resolve realResults

      if res.isSuccess
        @addPlayer identifier
        .then (res) =>
          player = @playerHash[identifier]
          realResults = player.getExtraDataForREST {player: yes, pet: yes, pets: yes, guildInvites: yes, guild: yes, global: yes}, baseResults
          realResults.token = player.tempSecureToken
          realResults.message = "Successful login. Welcome back to #{Constants.gameName}, #{player.getName()}!"
          return defer.resolve realResults

      else
        return defer.resolve {isSuccess: no, code: res.code, message: res.message}

      res

    defer.promise

  registerPlayer: (options) ->

    options.name = convenienceFunctions.sanitizeStringNoPunctuation options.name?.trim()

    return Q {isSuccess: no, code: 6, message: "You need a name for your character!"} unless options.name
    return Q {isSuccess: no, code: 2, message: "You have to make your name above 2 characters!"} if options.name.length < 2
    return Q {isSuccess: no, code: 3, message: "You have to keep your name under 20 characters!"} if options.name.length > 20
    return Q {isSuccess: no, code: 4, message: "You have to send a unique identifier for this player!"} if not options.identifier
    return Q {isSuccess: no, code: 4, message: "You can't have dots in your name. Sorry!"} if -1 isnt options.name.indexOf "."

    defer = Q.defer()

    playerObject = new Player options
    playerObject.playerManager = @
    playerObject.logger = @game.logManager.getLogger "Player"
    playerObject.initialize()
    playerObject.isOnline = yes
    playerObject.registrationDate = new Date()
    saveObj = @buildPlayerSaveObject playerObject
    saveObj._events = {}

    @db.insert saveObj, (iErr) =>

      return defer.resolve {isSuccess: no, code: 5, message: "Player creation error: #{iErr} (you probably already registered a character to that ident, that identifier is already taken, or that name is taken)."} if iErr

      @game.broadcast MessageCreator.genericMessage "Welcome #{options.name} to #{Constants.gameName}!"
      @playerHash[options.identifier] = playerObject
      @players.push playerObject

      playerObject.tempSecureToken = @generateTempToken()
      @beginWatchingPlayerStatistics playerObject
      @handleAutoLogout playerObject

      if options.password
        @storePasswordFor options.identifier, options.password
        .then =>
          @savePlayer playerObject

      defer.resolve {isSuccess: yes, code: 20, message: "Welcome to #{Constants.gameName}, #{options.name}!", player: saveObj, token: playerObject.tempSecureToken}

    defer.promise

  buildPlayerSaveObject: (player) ->
    realCalc = _.omit player.calc, 'self'
    calc = realCalc.base
    calcStats = realCalc.statCache
    badStats = ['cannotBeLoggedOut'
                'autoLogoutId'
                'playerManager'
                'party'
                'personalities'
                'calc'
                'spellsAffectedBy'
                'fled'
                '_events'
                'profession'
                'stepCooldown'
                '_oldAchievements'
                '_id'
                'logger'
                'pushbullet']
    ret = _.omit player, badStats
    ret._baseStats = calc
    ret._statCache = calcStats
    ret

  addForAnalytics: (player) ->
    playerObject = @buildPlayerSaveObject player
    playerObject.saveTime = new Date()
    @game.componentDatabase.insertNewAnalyticsPoint playerObject

  savePlayer: (player) ->
    savePlayer = @buildPlayerSaveObject player
    savePlayer.lastLogin = new Date()
    @db.update { name: player.name }, savePlayer, {upsert: true}, (e) =>
      @game.errorHandler.captureException e if e

  playerTakeTurn: (identifier, sendPlayerObject) ->
    return Q {isSuccess: no, code: 10, message: "You're not logged in!"} if not identifier or not (identifier of @playerHash)

    player = @playerHash[identifier]
    @handleAutoLogout player

    return if not sendPlayerObject

    Q player.getExtraDataForREST {player: yes, pet: yes, pets: yes, guildInvites: yes, guild: yes, global: yes}, {isSuccess: yes, code: 102, message: "Turn taken."}

  registerLoadAllPlayersHandler: (@playerLoadHandler) ->
    console.log "Registered AllPlayerLoad handler."

  handleAutoLogout: (player) ->
    return if player.cannotBeLoggedOut
    clearTimeout player.autoLogoutId if player.autoLogoutId
    player.autoLogoutId = setTimeout (@removePlayer.bind @, player.identifier), Constants.defaults.api.autoLogoutTime

  migratePlayer: (player) ->
    return if not player

    player.registrationDate = new Date() if not player.registrationDate

    player.gold = (new RestrictedNumber 0, 9999999999, 0) if not player.gold or not player.gold?.maximum

    loadRN = (obj) ->
      return if not obj
      obj.__current = 0 if _.isNaN obj.__current
      obj.__proto__ = RestrictedNumber.prototype
      obj

    loadProfession = (professionName) ->
      new (require "../../character/classes/#{professionName}")()

    loadEquipment = (equipment, autoequip = no) ->
      _.forEach equipment, (item) ->
        item.__proto__ = Equipment.prototype
        player.addToEquippedBy item if autoequip

    _.forEach ['hp', 'mp', 'special', 'level', 'xp', 'gold'], (item) ->
      player[item] = loadRN player[item]

    player.level.maximum = 200
    player.partyName = ''

    player.__proto__ = Player.prototype

    player.wildcard = yes
    player.listenerTree = {}
    player._events = {}
    player.newListener = false
    player.setMaxListeners 0

    player.playerManager = @
    player.isBusy = false
    player.loadCalc()

    player.logger = @game.logManager.getLogger "Player"

    player.guildTax = 0 unless player.guildTax

    player.handleGuildStatus()

    player.calc.itemFindRange()
    
    player.gender = _.sample ['male','female'] if not player.gender

    if not player.equipment
      player.generateBaseEquipment()
    else
      player.equipment = loadEquipment player.equipment, yes
      player.overflow = loadEquipment player.overflow

    player.special.name = ''
    if not player.professionName
      player.changeProfession "Generalist"
    else
      player.profession = loadProfession player.professionName
      player.profession.load player

    if not player.personalityStrings
      player.personalityStrings = []
      player.personalities = []
    else
      player.rebuildPersonalityList()

    if not player.priorityPoints
      player.priorityPoints = {dex: 1, str: 1, agi: 1, wis: 1, con: 1, int: 1}

    player.recalculateStats()

    player.spellsAffectedBy = []

    player.lastLogin = new Date()

    player.statistics = {} if not player.statistics
    player.permanentAchievements = {} if not player.permanentAchievements

    player.on "combat.self.kill", (defender) ->
      player.playerManager.game.battle?.broadcast "#{player.getName()}: #{player.messages.kill}" if player.messages?.kill
      return if not defender or defender.isMonster
      defender.modifyRelationshipWith player.name, -4
      player.modifyRelationshipWith defender.name, -4

    player.on "combat.self.killed", ->
      player.playerManager.game.battle?.broadcast "#{player.getName()}: #{player.messages.death}" if player.messages?.death

    player.on "combat.self.flee", ->
      player.playerManager.game.battle?.broadcast "#{player.getName()}: #{player.messages.flee}" if player.messages?.flee

    player.on "combat.ally.kill", (attacker) ->
      return if not attacker or attacker.isMonster
      player.modifyRelationshipWith attacker.name, 2
      attacker.modifyRelationshipWith player.name, 2

    player.on "combat.ally.flee", (fleer) ->
      return if not fleer or fleer.isMonster
      player.modifyRelationshipWith fleer.name, -10

    @beginWatchingPlayerStatistics player

    player

  getPlayerByName: (playerName) ->
    _.findWhere @players, {name: playerName}

  getPlayerById: (playerId) ->
    @playerHash[playerId]

  incrementPlayerSubmissions: (playerId) ->
    player = @getPlayerById playerId
    if player
      player.permanentAchievements.contentSubmissions = 0 if not player.permanentAchievements.contentSubmissions
      player.permanentAchievements.contentSubmissions++

    else
      @db.update {identifier: playerId}, {$inc: {'permanentAchievements.contentSubmissions': 1}}, ->

  beginWatchingPlayerStatistics: (player) ->

    maxStat = (stat, val) ->
      val = Math.abs val
      player.statistics[stat] = 1 if not (stat of player.statistics) or _.isNaN player.statistics[stat]
      player.statistics[stat] = Math.max val, player.statistics[stat]

    addStat = (stat, val, intermediate) ->
      player.statistics[intermediate] = {} if intermediate and not (intermediate of player.statistics) or _.isNaN player.statistics[intermediate]
      root = if intermediate then player.statistics[intermediate] else player.statistics
      val = Math.abs val
      root[stat] = 0 if not (stat of root) or _.isNaN root[stat]
      root[stat] += val

    handleRegion = (player) ->
      (addStat player.mapRegion, 1, "calculated regions visited") if player.oldRegion and player.mapRegion and player.oldRegion isnt player.mapRegion

    player.onAny ->
      player.statistics = {} if not player.statistics

      switch @event
        when "combat.self.heal"
          maxStat "calculated max healing given", arguments[1].damage
          addStat "calculated total healing given", arguments[1].damage

        when "combat.self.healed"
          addStat "calculated total healing received", arguments[1].damage

        when "combat.self.damage"
          maxStat "calculated max damage given", arguments[1].damage
          addStat "calculated total damage given", arguments[1].damage

        when "combat.self.damaged"
          addStat "calculated total damage received", arguments[1].damage

        when "combat.self.kill"
          addStat arguments[0].name, 1, "calculated kills" if not arguments[0].isMonster
          addStat arguments[0].professionName, 1, "calculated kills by class" if arguments[0].professionName

        when "player.profession.change"
          addStat arguments[2], 1, "calculated class changes"

        when "player.xp.gain"
          addStat "calculated total xp gained", arguments[1]

        when "player.xp.lose"
          addStat "calculated total xp lost", Math.abs arguments[1]

        when "player.gold.gain"
          addStat "calculated total gold gained", arguments[1]

        when "player.gold.lose"
          addStat "calculated total gold lost", Math.abs arguments[1]

        when "player.shop.buy"
          addStat "calculated total gold spent", Math.abs arguments[2]

        when "player.shop.petupgrade"
          addStat "calculated total gold spent", Math.abs arguments[1]

        when "player.gold.guildDonation"
          addStat arguments[0], (Math.abs arguments[1]), "calculated guild donations"

        when "player.gold.guildTax"
          addStat arguments[0], (Math.abs arguments[1]), "calculated guild taxes paid"

        when "explore.transfer"
          addStat arguments[1], 1, "calculated map changes"
          handleRegion arguments[0]

        when "explore.walk"
          handleRegion arguments[0]

        when "event.bossbattle.win"
          addStat arguments[1], 1, "calculated boss kills"

        when "event.treasurechest.find"
          addStat arguments[1], 1, "calculated treasure chests found"
          
        when "event.flipStat"
          maxStat "calculated biggest switcheroo", arguments[3]

      event = @event.split(".").join " "
      player.statistics[event] = 1 if not (event of player.statistics) or _.isNaN player.statistics[event]
      player.statistics[event]++
      player.statistics[event] = 1 if not player.statistics[event]

      player.checkAchievements()

module.exports = exports = PlayerManager
