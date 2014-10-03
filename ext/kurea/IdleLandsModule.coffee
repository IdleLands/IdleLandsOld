BotManager = require("../../../../core/BotManager").BotManager
_ = require "underscore"
_.str = require "underscore.string"
Q = require "q"

finder = require "fs-finder"
watch = require "node-watch"

c = require "irc-colors"

idlePath = __dirname + "/../../src"

module.exports = (Module) ->

  class IdleModule extends Module
    shortName: "IdleLands"
    helpText:
      default: "Nothing special here."

    serverBots: {}
    serverChannels: {}
    currentlyInChannels: []

    users: []
    userIdentsList: []
    userIdents: {}

    topic: "Welcome to Idletopia! New player? Join ##idlebot & read https://github.com/seiyria/IdleLands/wiki/New-Player-Guide | Got feedback? Send it to https://github.com/seiyria/IdleLands | Check your stats: http://kurea.link/idle"

    colorMap:
      "player.name":                c.bold
      "event.partyName":            c.underline
      "event.partyMembers":         c.bold
      "event.player":               c.bold
      "event.damage":               c.red
      "event.gold":                 c.olive
      "event.realGold":             c.olive
      "event.xp":                   c.green
      "event.realXp":               c.green
      "event.percentXp":            c.green
      "event.item.newbie":          c.brown
      "event.item.Normal":          c.gray
      "event.item.basic":           c.gray
      "event.item.pro":             c.purple
      "event.item.idle":            c.rainbow
      "event.item.godly":           c.white.bgblack
      "event.finditem.scoreboost":  c.bold
      "event.finditem.perceived":   c.bold
      "event.finditem.real":        c.bold
      "event.blessItem.stat":       c.bold
      "event.blessItem.value":      c.bold
      "event.flip.stat":            c.bold
      "event.flip.value":           c.bold
      "event.enchant.boost":        c.bold
      "event.enchant.stat":         c.bold
      "event.transfer.destination": c.bold
      "event.transfer.from":        c.bold
      "player.class":               c.italic
      "player.level":               c.bold
      "stats.hp":                   c.red
      "stats.mp":                   c.blue
      "stats.sp":                   c.olive
      "damage.hp":                  c.red
      "damage.mp":                  c.blue
      "spell.turns":                c.bold
      "spell.spellName":            c.underline
      "event.casterName":           c.bold
      "event.spellName":            c.underline
      "event.targetName":           c.bold
      "event.achievement":          c.underlines

    loadIdle: (stopIfLoaded) ->
      @buildUserList()
      if not (stopIfLoaded and @idleLoaded)
        @idleLoaded = true
        @IdleWrapper.load()
        @IdleWrapper.api.register.broadcastHandler @sendMessageToAll, @
        @IdleWrapper.api.register.colorMap @colorMap
        @IdleWrapper.api.register.playerLoadHandler @getAllUsers

    addServerChannel: (bot, server, channel) =>
      IdleModule::serverBots[server] = bot if not IdleModule::serverBots[server]

      if server of @serverChannels
        @serverChannels[server].push channel
      else
        @serverChannels[server] = [channel]

      @serverChannels[server] = _.uniq @serverChannels[server]

    removeServerChannel: (bot, server, channel) =>
      @serverChannels[server] = _.without @serverChannels[server], channel

    getAllUsers: =>
      @userIdentsList

    hashServerChannel: (server, channel) ->
      "#{server}/#{channel}"

    broadcast: (message) ->
      for server, channels of @serverChannels
        for channel in channels
          IdleModule::serverBots[server]?.say channel, message if (@hashServerChannel server, channel) in @currentlyInChannels

    sendMessageToAll: (message) ->
      @broadcast message

    generateIdent: (server, username) ->
      return null if not username
      "#{server}##{username}"

    addUser: (ident, suppress) ->
      return if not ident

      @userIdentsList.push ident
      @userIdentsList = _.uniq @userIdentsList

      @IdleWrapper.api.add.player ident, suppress

    removeUser: (ident) ->
      return if not ident or not _.contains @userIdentsList, ident
      @userIdentsList = _.without @userIdentsList, ident

      @IdleWrapper.api.remove.player ident

    buildUserList: ->
      for server, channels of @serverChannels
        for channel in channels
          bot = IdleModule::serverBots[server]
          if bot.conn.chans[channel]
            chanUsers = bot.getUsers channel
            chanUsers = _.forEach chanUsers, (user) =>
              #whois changes the prototype such that it breaks for subsequent calls even if the server changes
              #so we're doing nick-based auth for now
              bot.userManager.getUsername user, (e, username) =>
                username = user if (not username) and bot.config.auth is "nick"
                ident = @generateIdent server, username
                @addUser ident, yes

    loadOldChannels: ->
      Q.when @db.databaseReady, (db) =>
        db.find {active: true}, (e, docs) =>
          console.error e if e

          docs.each (e, doc) =>
            return if not doc
            bot = BotManager.botHash[doc.server]
            return if not bot
            @addServerChannel bot, doc.server, doc.channel

    beginGameLoop: ->
      DELAY_INTERVAL = 10000

      doActionPerMember = (arr, action) ->
        for i in [0...arr.length]
          setTimeout (player, i) ->
            action player
          , DELAY_INTERVAL/arr.length*i, arr[i]

      @interval = setInterval =>
        doActionPerMember @userIdentsList, @IdleWrapper.api.game.nextAction
      , DELAY_INTERVAL

    watchIdleFiles: ->
      loadFunction = _.debounce (=>@loadIdle()), 100
      watch idlePath, {}, () =>
        files = finder.from(idlePath).findFiles("*.coffee")

        _.forEach files, (file) ->
          delete require.cache[file]

        loadFunction()

    initialize: ->
      @loadIdle()
      @loadOldChannels()
      @beginGameLoop()
      @watchIdleFiles()

    isInChannel: (bot, nick) ->
      isIn = no
      for channel in @serverChannels[bot.config.server]
        chanUsers = bot.getUsers channel
        isIn = true if _.contains chanUsers, nick

      isIn

    constructor: (moduleManager) ->
      super moduleManager

      @IdleWrapper = require("../../src/system/ExternalWrapper")()
      @db = @newDatabase 'channels'

      @on "join", (bot, channel, sender) =>
        if bot.config.nick is sender
          setTimeout =>
            return if channel isnt '#idlebot'
            bot.send 'TOPIC', channel, @topic
            bot.send 'MODE', channel, '+m'
            @currentlyInChannels.push @hashServerChannel bot.config.server, channel
            @buildUserList()
          , 1000
          return

        bot.userManager.getUsername {user: sender, bot: bot}, (e, username) =>
          ident = @generateIdent bot.config.server, username
          @addUser ident
          @userIdents[@generateIdent bot.config.server, sender] = ident

      @on "part", (bot, channel, sender) =>
        return if channel isnt '#idlebot'
        bot.userManager.getUsername {user: sender, bot: bot}, (e, username) =>
          ident = @generateIdent bot.config.server, username
          @removeUser ident
          @userIdents[@generateIdent bot.config.server, sender] = ident

      @on "quit", (bot, sender) =>
        if bot.config.auth is "nickserv"
          @removeUser @generateIdent bot.config.server, @userIdents[@generateIdent bot.config.server, sender]
          delete @userIdents[@generateIdent bot.config.server, sender]
        else if bot.config.auth is "nick"
          @removeUser @generateIdent bot.config.server, sender

      @on "nick", (bot, oldNick, newNick) =>
        if bot.config.auth is "nickserv"
          @userIdents[@generateIdent bot.config.server, newNick] = @userIdents[@generateIdent bot.config.server, oldNick]
          delete @userIdents[@generateIdent bot.config.server, oldNick]
        else if bot.config.auth is "nick"
          @removeUser @generateIdent bot.config.server, oldNick
          @addUser @generateIdent bot.config.server, newNick

      @addRoute "idle-start", "idle.game.start", (origin) =>
        [channel, server] = [origin.channel, origin.bot.config.server]
        @db.update { channel: channel, server: server },
          { channel: channel, server: server, active: true },
          { upsert: true }, ->

        @addServerChannel origin.bot, server, channel
        @broadcast "#{origin.bot.config.server}/#{origin.channel} has joined the Idle Lands network!"

      @addRoute "idle-stop", "idle.game.stop", (origin, route) =>
        [channel, server] = [origin.channel, origin.bot.config.server]
        @db.update { channel: channel, server: server },
          { channel: channel, server: server, active: false },
          { upsert: true }, ->

        @broadcast "#{origin.bot.config.server}/#{origin.channel} has left the Idle Lands network!"
        @removeServerChannel origin.bot, server, channel

      registerCommand = (origin, route) =>
        [bot, name] = [origin.bot, route.params.name]

        name = name.trim()
        
        if name.length < 2
          @reply origin, "You have to make your name above 2 characters!"
          return

        if name.length > 20
          @reply origin, "You have to keep your name under 20 characters!"
          return

        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to services play this game!"
            return

          if not @isInChannel bot, username
            @reply origin, "You must be in the channel to actually play, duh!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.register.player
            identifier: identifier
            name: name
          , null, (status) =>
            if not status.success
              @reply origin, "You're already registered a character to that ident!"
            else if status.message
              @reply origin, status.message

      @addRoute "idle-register :name", registerCommand
      @addRoute "register :name", registerCommand

      @addRoute 'idle-event ":player" :event?', "idle.game.gm", (origin, route) =>
        [player, event] = [route.params.player, route.params.event]
        @IdleWrapper.api.game.doEvent player, event, (did) =>
          @reply origin, "Your event is done." if did
          @reply origin, "Your event failed (the player wasn't found)." if _.isUndefined did
          @reply origin, "Your event has failed (mysterious error, check the logs, or the event was just negative)." if did is false

      @addRoute 'idle-globalevent :event?', "idle.game.gm", (origin, route) =>
        event = route.params.event
        @IdleWrapper.api.game.doGlobalEvent event, (did) =>
          @reply origin, "Your event is done." if did
          @reply origin, "Your event failed (something weird went wrong)." if not did

      @addRoute 'idle-update', 'idle.game.gm', (origin) =>
        @IdleWrapper.api.game.update()

      @addRoute "idle-add event yesno \":question\" \":affirm\" \":deny\"", "idle.game.gm", (origin, route) =>
        [question, affirm, deny] = [route.params.question, route.params.affirm, route.params.deny]
        @IdleWrapper.api.add.yesno question, affirm, deny

      @addRoute "idle-add event :eventType \":question\"", "idle.game.gm", (origin, route) =>
        [eventType, question] = [route.params.eventType, route.params.question]

        if eventType not in ['blessXp', 'forsakeXp', 'blessGold', 'forsakeGold', 'blessItem', 'forsakeItem', 'findItem',
                             'party', 'battle']
          @reply origin, "#{eventType} isn't a valid event type."
          return

        @IdleWrapper.api.add.static eventType, question

      @addRoute "idle-ban :playerName", "idle.game.gm", (origin, route) =>
        [name] = [route.params.playerName]
        @IdleWrapper.api.game.banPlayer name

      @addRoute "idle-unban :playerName", "idle.game.gm", (origin, route) =>
        [name] = [route.params.playerName]
        @IdleWrapper.api.game.unbanPlayer name

      @addRoute 'idle-teleportloc ":playerName" :location', "idle.game.gm", (origin, route) =>
        [name, location] = [route.params.playerName, route.params.location]
        @IdleWrapper.api.game.teleport.singleLocation name, location

      @addRoute 'idle-teleport ":playerName" ":map" :x,:y', "idle.game.gm", (origin, route) =>
        [name, map, x, y] = [route.params.playerName, route.params.map, route.params.x, route.params.y]
        x = parseInt x
        y = parseInt y
        @IdleWrapper.api.game.teleport.single name, map, x, y

      @addRoute "idle-massteleportloc :location", "idle.game.gm", (origin, route) =>
        [location] = [route.params.location]
        @IdleWrapper.api.game.teleport.massLocation location

      @addRoute 'idle-massteleport ":map" :x,:y', "idle.game.gm", (origin, route) =>
        [map, x, y] = [route.params.map, route.params.x, route.params.y]
        x = parseInt x
        y = parseInt y
        @IdleWrapper.api.game.teleport.mass map, x, y

      @addRoute "idle-add item :itemOrDescType \":name\" *", "idle.game.gm", (origin, route) =>
        [type, name, parameters] = [route.params.itemOrDescType, route.params.name, route.splats[0]]

        if type not in ['prefix', 'suffix', 'prefix-special',
                        'body', 'charm', 'feet', 'finger', 'hands', 'head', 'legs', 'neck', 'offhand', 'mainhand']
          @reply origin, "#{type} isn't a valid type."
          return

        parameters = _.map (parameters.split ' '), (item) ->
          arr = item.split '='
          retval = {}
          retval[arr[0]] = (parseInt arr[1]) ? null
          retval
        .reduce (cur, prev) ->
          _.extend prev, cur
        , { name: name, type: type }

        @IdleWrapper.api.add.item parameters, (error) =>
          @reply origin, "You cannot have a duplicate name (#{error.name})." if error.name
          @reply origin, "It doesn't make sense to have the same stats twice." if error.stats

      @addRoute "idle-personality :action(remove|add) :personality", (origin, route) =>
        [bot, action, personality] = [origin.bot, route.params.action, route.params.personality]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your personality settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          msg = @IdleWrapper.api[action].personality identifier, personality
          if not msg
            @reply origin, "Could not #{action} the personality \"#{personality}\""
          else
            @reply origin, "Successfully updated your personality settings."

      @addRoute "idle-string :action(remove|add) :type :string?", (origin, route) =>
        [bot, action, sType, string] = [origin.bot, route.params.action, route.params.type, route.params.string]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your string settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          newString = @IdleWrapper.api[action].string identifier, sType, string
          @reply origin, "Successfully updated your string settings. String \"#{sType}\" is now: #{if newString then newString else 'empty!'}"

      @addRoute "idle-add all-data", "idle.game.owner", (origin, route) =>
        @reply origin, "Re-initializing all modifier/event/etc data from disk."
        @IdleWrapper.api.add.allData()

      @addRoute "idle-broadcast :message", "idle.game.owner", (origin, route) =>
        @broadcast "THIS IS A BROADCAST TO ALL IDLELANDS PLAYERS: #{route.params.message}"

      @addRoute "idle-gender :newGender", (origin, route) =>
        gender = route.params.newGender
        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your string settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          newGender = @IdleWrapper.api.set.gender identifier, gender
          @reply origin, "Your gender is now #{newGender}."

      @initialize()

      #@on "notice", (bot, sender, channel, message) =>
      #  return if not sender or sender in ['InfoServ','*','AUTH']
      #  console.log "notice from #{sender}|#{channel} on #{bot.config.server}: #{message}"

    destroy: ->
      clearInterval @interval
      delete @db
      super()

  IdleModule
