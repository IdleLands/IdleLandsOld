BotManager = require("../../../../core/BotManager").BotManager
_ = require "lodash"
_.str = require "underscore.string"
Q = require "q"

finder = require "fs-finder"
watch = require "node-watch"

c = require "irc-colors"

idlePath = __dirname + "/../../src"
try
  LogManager = require "../../src/system/managers/LogManager"
catch
  console.log "haha" # This is just here to not break stuff

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

    topic: "Welcome to Idliathlia! New player? Join ##idlebot & read http://new.idle.land | Got feedback? Send it to http://git.idle.land | Check your stats: http://idle.land/"

    colorMap:
      "player.name":                c.bold
      "event.partyName":            c.underline
      "event.partyMembers":         c.bold
      "event.player":               c.bold
      "event.damage":               c.red
      "event.gold":                 c.olive
      "event.realGold":             c.olive
      "event.shopGold":             c.olive
      "event.xp":                   c.green
      "event.realXp":               c.green
      "event.percentXp":            c.green
      "event.item.newbie":          c.brown
      "event.item.Normal":          c.gray
      "event.item.basic":           c.gray
      "event.item.pro":             c.purple
      "event.item.idle":            c.bold.rainbow
      "event.item.godly":           c.white.bgblack
      "event.item.custom":          c.white.bgblue
      "event.item.guardian":        c.cyan
      "event.finditem.scoreboost":  c.bold
      "event.finditem.perceived":   c.bold
      "event.finditem.real":        c.bold
      "event.blessItem.stat":       c.bold
      "event.blessItem.value":      c.bold
      "event.flip.stat":            c.bold
      "event.flip.value":           c.bold
      "event.enchant.boost":        c.bold
      "event.enchant.stat":         c.bold
      "event.tinker.boost":         c.bold
      "event.tinker.stat":          c.bold
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
      "event.achievement":          c.underline
      "event.guildName":            c.underline

    loadIdle: (stopIfLoaded) ->
      @buildUserList()
      if not (stopIfLoaded and @idleLoaded)
        @idleLoaded = true
        try
          @IdleWrapper.load()
          @IdleWrapper.api.game.handlers.broadcastHandler @sendMessageToAll, @
          @IdleWrapper.api.game.handlers.colorMap @colorMap
          @IdleWrapper.api.game.handlers.playerLoadHandler @getAllUsers
        catch e
          console.error e

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

      @IdleWrapper.api.player.auth.login ident, suppress

    removeUser: (ident) ->
      return if not ident or not _.contains @userIdentsList, ident
      @userIdentsList = _.without @userIdentsList, ident

      @IdleWrapper.api.player.auth.logout ident

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
        doActionPerMember @userIdentsList, (identifier) => @IdleWrapper.api.player.takeTurn identifier, no
      , DELAY_INTERVAL

    watchIdleFiles: ->
      loadFunction = _.debounce (=>@loadIdle()), 100
      watch idlePath, {}, () ->
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

      @IdleWrapper = require("../../src/system/accessibility/ExternalWrapper")()
      @db = @newDatabase 'channels'
      try
        @logManager = new LogManager()
        logger = @logManager.getLogger "kureaModule"
        logger.warn "This is actually a success"
      catch
        console.log "useless catch to satisfy stuff." #it's here so that if it doesn't work, it won't break.

      @on "join", (bot, channel, sender) =>
        if bot.config.nick is sender
          setTimeout =>
            return if channel isnt '#idlebot-test'
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
        return if channel isnt '#idlebot-test'
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

      `/**
        * Start the game on the server this is run on. Used when linking new IRC networks.
        *
        * @name idle-start
        * @syntax !idle-start
        * @gmOnly
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-start", "idle.game.start", (origin) =>
        console.log "idle-start!"
        [channel, server] = [origin.channel, origin.bot.config.server]
        @db.update { channel: channel, server: server },
          { channel: channel, server: server, active: true },
          { upsert: true }, ->

        @addServerChannel origin.bot, server, channel
        @broadcast "#{origin.bot.config.server}/#{origin.channel} has joined the Idle Lands network!"

      `/**
        * Stop the game server on the server this is run on.
        *
        * @name idle-stop
        * @syntax !idle-stop
        * @gmOnly
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-stop", "idle.game.stop", (origin, route) =>
        [channel, server] = [origin.channel, origin.bot.config.server]
        @db.update { channel: channel, server: server },
          { channel: channel, server: server, active: false },
          { upsert: true }, ->

        @broadcast "#{origin.bot.config.server}/#{origin.channel} has left the Idle Lands network!"
        @removeServerChannel origin.bot, server, channel

      registerCommand = (origin, route) =>
        [bot, name] = [origin.bot, route.params.name]

        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to services play this game!"
            return

          if not @isInChannel bot, username
            @reply origin, "You must be in the channel to actually play, duh!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.auth.register
            identifier: identifier
            name: name
          ).then (res) =>
            @reply origin, res.message

      `/**
        * Register a new character on this IRC network.
        *
        * @name idle-register
        * @syntax !idle-register Character Name
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-register :name", registerCommand
      @addRoute "register :name", registerCommand

      `/**
        * Run any event for any logged in player.
        *
        * @name idle-event
        * @syntax !idle-event "Player Name" eventType
        * @gmOnly
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-event ":player" :event', "idle.game.gm", (origin, route) =>
        [player, event] = [route.params.player, route.params.event]
        @IdleWrapper.api.gm.event.single player, event

      `/**
        * Run a global event (cataclysms, PvP battles, etc).
        *
        * @name idle-globalevent
        * @gmOnly
        * @syntax !idle-globalevent eventType
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-globalevent :event?', "idle.game.gm", (origin, route) =>
        event = route.params.event
        @IdleWrapper.api.gm.event.global event

      `/**
        * Reset a password for a player.
        *
        * @name idle-resetpassword
        * @gmOnly
        * @syntax !idle-resetpassword "identifier" "newPassword"
        * @example !idle-resetpassword "local-server/Danret" "my new awesome password"
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-resetpassword ":identifier" ":newPassword"', "idle.game.gm", (origin, route) =>
        try
          [identifier, password] = [route.params.identifier, route.params.newPassword]
          if @gameInstance and @gameInstance.playerManager
            @gameInstance.playerManager.storePasswordFor identifier, password
          else
            @IdleWrapper.api.gm.data.setPassword identifier, password
        catch e
          logger = @logManager.getLogger "kureaModule"
          logger.error "!idle-resetpassword error", {e}

      `/**
       * Change a players identifier.
       *
       * @name idle-changeident
       * @gmOnly
       * @syntax !idle-changeident "identifier" "newIdentifier"
       * @example !idle-changeident "local-server/Danret" "local-server/AlsoDanret"
       * @category IRC Commands
       * @package Client
       */`
      @addRoute 'idle-changeident ":identifier" ":newIdentifier"', "idle.game.gm", (origin, route) =>
        [identifier, newIdentifier] = [route.params.identifier, route.params.newIdentifier]
        @gameInstance.api.gm.status.identifierChange identifier, newIdentifier

      `/**
        * Force the bot to update IdleLands and reboot.
        *
        * @name idle-update
        * @gmOnly
        * @syntax !idle-update
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-update', 'idle.game.gm', =>
        @IdleWrapper.api.gm.data.update()

      `/**
        * Ban a player.
        *
        * @name idle-ban
        * @gmOnly
        * @syntax !idle-ban Player Name
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-ban :playerName", "idle.game.gm", (origin, route) =>
        [name] = [route.params.playerName]
        @IdleWrapper.api.gm.status.ban name

      `/**
        * Unban a player.
        *
        * @name idle-unban
        * @gmOnly
        * @syntax !idle-unban Player Name
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-unban :playerName", "idle.game.gm", (origin, route) =>
        [name] = [route.params.playerName]
        @IdleWrapper.api.gm.status.unban name

      `/**
        * Teleport a player to a given location.
        *
        * @name idle-teleportloc
        * @gmOnly
        * @syntax !idle-teleportloc "Player Name" locationId
        * @example !idle-teleport "Swirly" start
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-teleportloc ":playerName" :location', "idle.game.gm", (origin, route) =>
        [name, location] = [route.params.playerName, route.params.location]
        @IdleWrapper.api.gm.teleport.location.single name, location

      `/**
        * Teleport a player to a given set of coordinates.
        *
        * @name idle-teleport
        * @gmOnly
        * @syntax !idle-teleport "Player Name" "Map Name" x,y
        * @example !idle-teleport "Swirly" "Norkos" 10,10
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-teleport ":playerName" ":map" :x,:y', "idle.game.gm", (origin, route) =>
        [name, map, x, y] = [route.params.playerName, route.params.map, route.params.x, route.params.y]
        x = parseInt x
        y = parseInt y
        @IdleWrapper.api.gm.teleport.map.single name, map, x, y

      `/**
        * Teleport all players to a given location.
        *
        * @name idle-massteleportloc
        * @gmOnly
        * @syntax !idle-massteleportloc locationId
        * @example !idle-massteleportloc norkos
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-massteleportloc :location", "idle.game.gm", (origin, route) =>
        [location] = [route.params.location]
        @IdleWrapper.api.gm.teleport.map.location location

      `/**
        * Teleport all players to a given set of coordinates.
        *
        * @name idle-massteleport
        * @gmOnly
        * @syntax !idle-massteleport "Map Name" x,y
        * @example !idle-massteleport "Norkos" 10,10
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-massteleport ":map" :x,:y', "idle.game.gm", (origin, route) =>
        [map, x, y] = [route.params.map, route.params.x, route.params.y]
        x = parseInt x
        y = parseInt y
        @IdleWrapper.api.gm.teleport.map.mass map, x, y

      `/**
        * Generate a custom item for a player.
        *
        * @name idle-itemgen
        * @gmOnly
        * @syntax !idle-itemgen "Player Name" itemSlot "name" stats
        * @example !idle-itemgen "Swirly" mainhand "Epic Cheat" luck=10000
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-itemgen ":player" :type *', "idle.game.gm", (origin, route) =>
        [playerName, itemType, itemData] = [route.params.player, route.params.type, route.splats[0]]
        @IdleWrapper.api.gm.player.createItem playerName, itemType, itemData

      `/**
       * Give a player some gold.
       *
       * @name idle-goldgive
       * @gmOnly
       * @syntax !idle-goldgive "Player Name" gold
       * @example !idle-goldgive "Swirly" 10000
       * @category IRC Commands
       * @package Client
       */`
      @addRoute 'idle-goldgive ":player" :gold', "idle.game.gm", (origin, route) =>
        [playerName, gold] = [route.params.player, route.params.gold]
        @IdleWrapper.api.gm.player.giveGold playerName, parseInt gold

      `/**
        * Modify your personality settings.
        *
        * @name idle-personality
        * @syntax !idle-personality add|remove Personality
        * @example !idle-personality add ScaredOfTheDark
        * @example !idle-personality remove ScaredOfTheDark
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-personality :action(add|remove) :personality", (origin, route) =>
        [bot, action, personality] = [origin.bot, route.params.action, route.params.personality]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your personality settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.personality[action] identifier, personality)
          .then (res) =>
            @reply origin, res.message

      stringFunc = (origin, route) =>
        [bot, action, sType, string] = [origin.bot, route.params.action, route.params.type, route.params.string]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your string settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.string[action] identifier, sType, string)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Modify your string settings.
        *
        * @name idle-string
        * @syntax !idle-string add|remove type [stringData]
        * @example !idle-string set web This is my web string
        * @example !idle-string remove web
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-string :action(set) :type :string", stringFunc
      @addRoute "idle-string :action(remove) :type", stringFunc

      pushbulletFunc = (origin, route) =>
        [bot, action, string] = [origin.bot, route.params.action, route.params.string]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your string settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.pushbullet[action] identifier, string)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Modify your PushBullet settings.
        *
        * @name idle-pushbullet
        * @syntax !idle-pushbullet set|remove [pushbulletApiKey]
        * @example !idle-pushbullet set ThisIsAnAPIKey
        * @example !idle-pushbullet remove
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-pushbullet :action(set) :string", pushbulletFunc
      @addRoute "idle-pushbullet :action(remove)", pushbulletFunc

      `/**
        * Modify your priority point settings.
        *
        * @name idle-priority
        * @syntax !idle-priority add|remove stat points
        * @example !idle-priority add str 1
        * @example !idle-priority remove str 1
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-priority :action(add|remove) :stat :points", (origin, route) =>
        [bot, action, stat, points] = [origin.bot, route.params.action, route.params.stat, route.params.points]
        bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your priority settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.priority[action] identifier, stat, points)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Modify your gender settings.
        *
        * @name idle-gender
        * @syntax !idle-gender newGender
        * @example !idle-gender male
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-gender :newGender", (origin, route) =>
        gender = route.params.newGender
        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your gender settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.gender.set identifier, gender
          .then (ret) =>
            @reply origin, ret.message

      `/**
       * Teleport yourself to somewhere you've been before.
       *
       * @name idle-teleportself
       * @syntax !idle-teleportself townCname
       * @example !idle-teleportself norkos
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-teleportself :newLoc", (origin, route) =>
        newLoc = route.params.newLoc
        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to teleport yourself!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.action.teleport identifier, newLoc
          .then (ret) =>
            @reply origin, ret.message

      `/**
        * Modify your title.
        *
        * @name idle-title
        * @syntax !idle-title newTitle
        * @example !idle-title Entitled
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-title :newTitle", (origin, route) =>
        newTitle = route.params.newTitle
        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your title settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.title.set identifier, newTitle
          .then (ret) =>
            @reply origin, ret.message

      `/**
        * Modify your inventory.
        *
        * @name idle-inventory
        * @syntax !idle-inventory swap|sell|add slot
        * @example !idle-inventory add mainhand
        * @example !idle-inventory swap 0
        * @example !idle-inventory sell 0
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-inventory :action(swap|sell|add) :slot", (origin, route) =>
        [action, slot] = [route.params.action, route.params.slot]
        slot = parseInt slot if action isnt "add"

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change your inventory settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.overflow[action] identifier, slot)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Purchase something from a nearby shop (if you're near one, of course).
        *
        * @name idle-shop
        * @syntax !idle-shop buy slot
        * @example !idle-shop buy 0
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-shop buy :slot", (origin, route) =>
        [slot] = [route.params.slot]
        slot = parseInt slot

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to buy from a shop!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.shop.buy identifier, slot)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Create a new guild. Costs 100k.
        *
        * @name Guild Creation
        * @syntax !idle-guild create guildName
        * @example !idle-guild create Leet Admin Hax
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild create :guildName", (origin, route) =>
        [guildName] = [route.params.guildName]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to create a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild.create identifier, guildName)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Manage guild members.
        *
        * @name Guild Management
        * @syntax !idle-guild invite|promote|demote|kick Player Name
        * @example !idle-guild invite Swirly
        * @example !idle-guild promote Swirly
        * @example !idle-guild demote Swirly
        * @example !idle-guild kick Swirly
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild :action(invite|promote|demote|kick) :playerName", (origin, route) =>
        [action, playerName] = [route.params.action, route.params.playerName]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to administer a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild[action] identifier, playerName)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Manage your guild's current location.
       *
       * @name idle-guild move
       * @syntax !idle-guild move newLoc
       * @example !idle-guild move Vocalnus
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild move :newLoc", (origin, route) =>
        [newLoc] = [route.params.newLoc]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to administer a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild.move identifier, newLoc)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Construct a new building in your Guild Hall.
       *
       * @name idle-guild construct
       * @syntax !idle-guild construct building slot
       * @example !idle-guild construct GuildHall 0
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild construct :building :slot", (origin, route) =>
        [building, slot] = [route.params.building, parseInt route.params.slot]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to administer a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild.construct identifier, building, slot)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Upgrade a building in your guild hall.
       *
       * @name idle-guild upgrade
       * @syntax !idle-guild upgrade building
       * @example !idle-guild upgrade GuildHall
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild upgrade :building", (origin, route) =>
        [building] = [route.params.building]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to administer a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild.upgrade identifier, building)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Set a specific property for a building in your Guild Hall.
       *
       * @name idle-guild setprop
       * @syntax !idle-guild setprop building prop "value"
       * @example !idle-guild setprop Mascot MascotID "Skeleton"
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild setprop :building :prop \":value\"", (origin, route) =>
        [building, prop, value] = [route.params.building, route.params.prop, route.params.value]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to administer a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild.setProperty identifier, building, prop, value)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Manage your guild status.
        *
        * @name Guild Status
        * @syntax !idle-guild leave|disband
        * @example !idle-guild leave
        * @example !idle-guild disband
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild :action(leave|disband)", (origin, route) =>

        [action] = [route.params.action]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to manage your guild status!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.guild[action] identifier)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Manage your guild invitations.
        *
        * @name Guild Invitations
        * @syntax !idle-guild manage-invite accept|deny guild name
        * @example !idle-guild manage-invite accept Leet Admin Hax
        * @example !idle-guild manage-invite deny Leet Admin Hax
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild manage-invite :action(accept|deny) :guildName", (origin, route) =>
        [action, guildName] = [route.params.action, route.params.guildName]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to join a guild!"
            return

          identifier = @generateIdent origin.bot.config.server, username
          accepted = action is "accept"

          (@IdleWrapper.api.player.guild.manageInvite identifier, accepted, guildName)
          .then (res) =>
            @reply origin, res.message

      `/**
        * Donate gold to your guild.
        *
        * @name Guild Donation
        * @syntax !idle-guild donate gold
        * @example !idle-guild donate 1337
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild donate :gold", (origin, route) =>
        [gold] = [route.params.gold]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to donate gold!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.guild.donate identifier, parseInt gold
          .then (res) =>
            @reply origin, res.message

      `/**
        * Purchase a buff for your guild.
        *
        * @name Guild Buff
        * @syntax !idle-guild buff "type" tier
        * @example !idle-guild buff "Strength" 1
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-guild buff \":type\" :tier", (origin, route) =>
        [type, tier] = [route.params.type, route.params.tier]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to buy a guild buff!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.guild.buff identifier, type, parseInt tier
          .then (res) =>
            @reply origin, res.message

      `/**
       * Adjust your guilds tax rate (anywhere from 0-15%). Only guild leaders can set this.
       *
       * @name idle-guild tax
       * @syntax !idle-guild tax taxPercent
       * @example !idle-guild tax 15
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild tax :taxPercent", (origin, route) =>
        [taxPercent] = [route.params.taxPercent]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to manage your guilds taxes!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.guild.tax.whole identifier, parseInt taxPercent
          .then (res) =>
            @reply origin, res.message

      `/**
       * Adjust your personal tax rate to pay to your guild (anywhere from 0-85%).
       *
       * @name idle-guild selftax
       * @syntax !idle-guild selftax taxPercent
       * @example !idle-guild selftax 15
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-guild selftax :taxPercent", (origin, route) =>
        [taxPercent] = [route.params.taxPercent]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to manage your taxes!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.guild.tax.self identifier, parseInt taxPercent
          .then (res) =>
            @reply origin, res.message

      `/**
        * Manage your password, or authenticate.
        *
        * @name idle-secure
        * @syntax !idle-secure setPassword|authenticate password
        * @example !idle-secure setPassword my super secret password
        * @example !idle-secure authenticate my super secret password
        * @category IRC Commands
        * @package Client
      */`
      @addRoute "idle-secure :action(setPassword|authenticate) :password", (origin, route) =>
        [action, password] = [route.params.action, route.params.password]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to set a password!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.auth[action] identifier, password)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Buy a new pet.
       *
       * @name idle-pet buy
       * @syntax !idle-pet buy "type" "name" "attr1" "attr2"
       * @example !idle-pet buy "Pet Rock" "Rocky" "a top hat" "a monocle"
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-pet buy \":petType\" \":petName\" \":attr1\" \":attr2\"", (origin, route) =>
        [type, name, attr1, attr2] = [route.params.petType, route.params.petName, route.params.attr1, route.params.attr2]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to buy a pet!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.pet.buy identifier, type, name, attr1, attr2)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Set smart options for your pet.
       *
       * @name idle-pet set
       * @syntax !idle-pet set option on|off
       * @example !idle-pet set smartSell on
       * @example !idle-pet set smartSelf on
       * @example !idle-pet set smartEquip off
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-pet set :option :value", (origin, route) =>
        [option, value] = [route.params.option, route.params.value is "on"]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change pet settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.pet.setOption identifier, option, value)
          .then (res) =>
            @reply origin, res.message

      `/**
       * Manage your pets items, upgrade their stats, and feed them gold!
       *
       * @name idle-pet action
       * @syntax !idle-pet action actionType actionParameter
       * @syntax !idle-pet action upgrade <stat> (maxLevel | inventory | goldStorage | battleJoinPercent | itemFindTimeDuration | itemSellMultiplier | itemFindBonus | itemFindRangeMultiplier | xpPerGold | maxItemScore)
       * @syntax !idle-pet action giveEquipment itemSlot
       * @syntax !idle-pet action sellEquipment itemSlot
       * @syntax !idle-pet action takeEquipment itemSlot
       * @syntax !idle-pet action changeClass newClass
       * @syntax !idle-pet action equipItem itemSlot
       * @syntax !idle-pet action unequipItem itemUid
       * @syntax !idle-pet action swapToPet petId
       * @syntax !idle-pet action feed
       * @syntax !idle-pet action takeGold
       * @example !idle-pet action upgrade maxLevel
       * @example !idle-pet action giveEquipment 0
       * @example !idle-pet action takeEquipment 1
       * @example !idle-pet action sellEquipment 2
       * @example !idle-pet action changeClass Generalist
       * @example !idle-pet action equipItem 3
       * @example !idle-pet action unequipItem 1418554184641
       * @example !idle-pet action swapToPet 1418503227081
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-pet action :action(feed|takeGold)", (origin, route) =>
        [action] = [route.params.action]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change pet settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.pet[action]? identifier)
          .then (res) =>
            @reply origin, res.message

      @addRoute "idle-pet action :action :param", (origin, route) =>
        [action, param] = [route.params.action, route.params.param]
        param = parseInt param if not (action in ["upgrade", "changeClass"])

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to change pet settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          (@IdleWrapper.api.player.pet[action]? identifier, param)?.then (res) =>
            @reply origin, res.message

      `/**
       * Manage custom data for the game.
       *
       * @name idle-customdata
       * @gmOnly
       * @syntax !idle-customdata <command> (init | update)
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-customdata :action", "idle.game.gm", (origin, route) =>
        [action] = [route.params.action]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to manage custom data!"
            return

          @IdleWrapper.api.gm.custom[action]?()

      `/**
       * Manage moderators for managing custom data for the game.
       *
       * @name idle-custommod
       * @gmOnly
       * @syntax !idle-custommod "<user-identifier>" status
       * @example !idle-custommod "local-server/Danret" 1
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-custommod \":identifier\" :mod", "idle.game.gm", (origin, route) =>
        [identifier, modStatus] = [route.params.identifier, parseInt route.params.mod]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to manage custom mods!"
            return

          @IdleWrapper.api.gm.custom.modModerator identifier, modStatus
      `/**
       * Set a logger's level.
       *
       * @name idle-setloggerlevel
       * @gmOnly
       * @syntax !idle-setloggerlevel name level
       * @example !idle-setloggerlevel battle debug
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-setloggerlevel \":name\" :level", "idle.game.gm", (origin, route) =>
        [name, level] = [route.params.name, route.params.level]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to set log levels!"
            return

          @IdleWrapper.api.gm.log.setLoggerLevel name, level

      `/**
       * Clear a log.
       *
       * @name idle-clearlog
       * @gmOnly
       * @syntax !idle-clearlog name
       * @example !idle-clearlog battle
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-clearlog \":name\"", "idle.game.gm", (origin, route) =>
        [name] = [route.params.name]

        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to set log levels!"
            return

          @IdleWrapper.api.gm.log.clearLog name

      `/**
       * Clear all log.
       *
       * @name idle-clearalllogs
       * @gmOnly
       * @syntax !idle-clearalllogs
       * @example !idle-clearalllogs
       * @category IRC Commands
       * @package Client
       */`
      @addRoute "idle-clearalllogs", "idle.game.gm", (origin, route) =>
        origin.bot.userManager.getUsername origin, (e, username) =>
          if not username
            @reply origin, "You must be logged in to set log levels!"
            return

          @IdleWrapper.api.gm.log.clearAllLogs()

      @initialize()

      #@on "notice", (bot, sender, channel, message) =>
      #  return if not sender or sender in ['InfoServ','*','AUTH']
      #  console.log "notice from #{sender}|#{channel} on #{bot.config.server}: #{message}"

    destroy: ->
      clearInterval @interval
      delete @db
      super()

  IdleModule
