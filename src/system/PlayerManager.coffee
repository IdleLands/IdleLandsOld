
Datastore = require "./DatabaseWrapper"
_ = require "underscore"
Player = require "../character/player/Player"
Equipment = require "../item/Equipment"
RestrictedNumber = require "restricted-number"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
bcrypt = require "bcrypt-nodejs"
crypto = require "crypto"

class PlayerManager

  players: []
  playerHash: {}

  constructor: (@game) ->
    @db = new Datastore "players", (db) ->
      db.ensureIndex { identifier: 1 }, { unique: true }, ->
      db.ensureIndex { name: 1 }, { unique: true }, ->

      db.update {}, {$set:{isOnline: no}}, {multi: yes}, ->

    @interval = null
    @DELAY_INTERVAL = 10000
    @beginGameLoop()

  beginGameLoop: ->

    doActionPerMember = (arr, action) ->
      for i in [0...arr.length]
        setTimeout (player, i) ->
          action player
        , @DELAY_INTERVAL/arr.length*i, arr[i]

    @interval = setInterval =>
      (doActionPerMember @players, ((player) -> player.takeTurn())) if @players.length > 0
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

  hashPassword: (password) ->
    bcrypt.hashSync password

  storePasswordFor: (identifier, password) ->
    password = password.trim()
    player = @playerHash[identifier]

    return Q {isSuccess: no, code: 1, message: "Please use a password > 3 characters."} if password.length < 3
    return Q {isSuccess: no, code: 10, message: "You're not logged in!"} if not player

    player.password = @hashPassword password

    Q {isSuccess: yes, code: 17, message: "Your password has been set! Extraneous spaces at be beginning and end have been removed!"}

  checkToken: (identifier, token) ->

    player = @playerHash[identifier]

    return Q {isSuccess: no, code: 10, message: "You're not logged in!"} if not player
    return Q {isSuccess: no, code: -1, message: "That token isn't valid!"} if player?.tempSecureToken isnt token

    Q {isSuccess: yes, code: 999999, message: "Valid token. Carry on."} #lol

  checkPassword: (identifier, password, isIRC = no) ->

    defer = Q.defer()

    return Q {isSuccess: no, code: 12, message: "You're not currently logged in, so you can't auth via password."} if isIRC and not @playerHash[identifier]
    return Q {isSuccess: no, code: 16, message: "You can't login without a password, silly!"} if not password

    @db.findOne {identifier: identifier}, (e, player) ->
      console.error "BAD CHECK PASSWORD",e,e.stack if e

      defer.resolve {isSuccess: no, code: 13, message: "Authentication failure (player doesn't exist)."} if not player
      defer.resolve {isSuccess: no, code: 12, message: "You haven't set up a password yet!"} if not player?.password
      defer.resolve {isSuccess: no, code: 14, message: "Authentication failure (bad password)."} if not bcrypt.compareSync password, player?.password

      defer.resolve {isSuccess: yes, code: 999999, message: "Successful login. Welcome back!"} #lol

    defer.promise

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
      @game.broadcast "#{player.name}, the level #{player.level.__current} #{player.professionName}, has joined #{Constants.gameName}!" if not suppress

      @players = _.uniq @players
      player.tempSecureToken = @generateTempToken()

      player.cannotBeLoggedOut = not autoLogout
      @handleAutoLogout player

      defer.resolve
        isSuccess: yes
        code: 18
        message: "Successful login. Welcome back to #{Constants.gameName}, #{player.name}!"
        token: player.tempSecureToken
        player: player.buildRESTObject()

    defer.promise

  removePlayer: (identifier) ->

    player = @playerHash[identifier]
    return Q {isSuccess: no, code: 13, message: "Player not found."} if not player

    player.isOnline = no
    player.tempSecureToken = null
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
      player = @playerHash[identifier]
      return defer.resolve {isSuccess: yes, code: 15, message: "This is a duplicate login session.", player: player.buildRESTObject(), token: player.tempSecureToken} if @playerHash[identifier]
      if res.isSuccess
        @addPlayer identifier
        .then (res) =>
          player = @playerHash[identifier]
          return defer.resolve {isSuccess: yes, code: 15, message: "Successful login.", player: player.buildRESTObject(), token: player.tempSecureToken} if @playerHash[identifier]

      res

    defer.promise

  registerPlayer: (options) ->

    options.name = options.name?.trim()

    return Q {isSuccess: no, code: 6, message: "You need a name for your character!"} if not options.name
    return Q {isSuccess: no, code: 2, message: "You have to make your name above 2 characters!"} if options.name.length < 2
    return Q {isSuccess: no, code: 3, message: "You have to keep your name under 20 characters!"} if options.name.length > 20
    return Q {isSuccess: no, code: 4, message: "You have to send a unique identifier for this player!"} if not options.identifier

    defer = Q.defer()

    playerObject = new Player options
    playerObject.playerManager = @
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
                '_id'
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
    @db.update { identifier: player.identifier }, savePlayer, {upsert: true}, (e) ->
      console.error "Save error: #{e}" if e

  playerTakeTurn: (identifier) ->
    return Q {isSuccess: no, code: 10, message: "You're not logged in!"} if not identifier or not (identifier of @playerHash)

    player = @playerHash[identifier]
    @handleAutoLogout player

    Q {isSuccess: yes, code: 102, message: "Turn taken.", player: player.buildRESTObject()}

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
      new (require "../character/classes/#{professionName}")()

    loadEquipment = (equipment) ->
      _.forEach equipment, (item) ->
        item.__proto__ = Equipment.prototype

    _.forEach ['hp', 'mp', 'special', 'level', 'xp', 'gold'], (item) ->
      player[item] = loadRN player[item]

    player.__proto__ = Player.prototype

    player.wildcard = yes
    player.listenerTree = {}
    player._events = {}
    player.newListener = false
    player.setMaxListeners 100

    player.playerManager = @
    player.isBusy = false
    player.loadCalc()

    player.handleGuildStatus()

    player.calc.itemFindRange()

    if not player.equipment
      player.generateBaseEquipment()
    else
      player.equipment = loadEquipment player.equipment
      player.overflow = loadEquipment player.overflow

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

    @beginWatchingPlayerStatistics player

    player

  getPlayerByName: (playerName) ->
    _.findWhere @players, {name: playerName}

  getPlayerById: (playerId) ->
    @playerHash[playerId]

  beginWatchingPlayerStatistics: (player) ->

    maxStat = (stat, val) ->
      val = Math.abs val
      player.statistics[stat] = 1 if not (stat of player.statistics) or _.isNaN player.statistics[stat]
      player.statistics[stat] = Math.max val, player.statistics[stat]

    addStat = (stat, val, intermediate) ->
      player.statistics[intermediate] = {} if intermediate and not (intermediate of player.statistics)
      root = if intermediate then player.statistics[intermediate] else player.statistics
      val = Math.abs val
      root[stat] = 0 if not (stat of root) or _.isNaN root[stat]
      root[stat] += val

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

        when "explore.transfer"
          addStat arguments[1], 1, "calculated map changes"

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
