BotManager = require("../../../../core/BotManager").BotManager
_ = require "lodash"
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
        doActionPerMember @userIdentsList, @IdleWrapper.api.player.takeTurn
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
        @IdleWrapper.api.gm.event.single player, event, (did) =>
          @reply origin, "Your event is done." if did
          @reply origin, "Your event failed (the player wasn't found)." if _.isUndefined did
          @reply origin, "Your event has failed (mysterious error, check the logs, or the event was just negative)." if did is false

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
        @IdleWrapper.api.gm.event.global event, (did) =>
          @reply origin, "Your event is done." if did
          @reply origin, "Your event failed (something weird went wrong)." if not did

      `/**
        * Reset a password for a player.
        *
        * @gmOnly
        * @syntax !idle-resetpassword "identifier" "newPassword"
        * @example !idle-resetpassword "local-server/Danret" "my new awesome password"
        * @category IRC Commands
        * @package Client
      */`
      @addRoute 'idle-resetpassword ":identifier" ":newPassword"', "idle.game.gm", (origin, route) =>
        [identifier, password] = [route.params.identifier, route.params.newPassword]
        @gameInstance.playerManager.storePasswordFor identifier, password

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
            @reply origin, "You must be logged in to change your string settings!"
            return

          identifier = @generateIdent origin.bot.config.server, username

          @IdleWrapper.api.player.gender.set identifier, gender
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

      @initialize()

      #@on "notice", (bot, sender, channel, message) =>
      #  return if not sender or sender in ['InfoServ','*','AUTH']
      #  console.log "notice from #{sender}|#{channel} on #{bot.config.server}: #{message}"

    destroy: ->
      clearInterval @interval
      delete @db
      super()

  IdleModule
