BotManager = require("../../../../core/BotManager").BotManager
_ = require "underscore"
Q = require "q"

finder = require "fs-finder"

watch = require "node-watch"
idlePath = __dirname+"/../../src"

module.exports = (Module) ->

	class IdleModule extends Module
		shortName: "IdleLands"
		helpText:
			default: "Nothing special here."

		serverBots: {}
		serverChannels: {}

		users: []
		userIdentsList: []
		userIdents: {}

		loadIdle: (stopIfLoaded) ->
			@buildUserList() if not @users.length
			if not (stopIfLoaded and @idleLoaded)
				@idleLoaded = true
				@IdleWrapper.load()
				@IdleWrapper.api.register.broadcastHandler @sendMessageToAll, @
				@IdleWrapper.api.register.playerLoadHandler @getAllUsers

		addServerChannel: (bot, server, channel) =>
			@serverBots[server] = bot

			if server of @serverChannels
				@serverChannels[server].push channel
			else
				@serverChannels[server] = [channel]

			@serverChannels[server] = _.uniq @serverChannels[server]

		removeServerChannel: (bot, server, channel) =>
			@serverChannels[server] = _.without @serverChannels[server], channel

		getAllUsers: =>
			@userIdentsList

		broadcast: (message) ->
			for server, channels of @serverChannels
				for channel in channels
					@serverBots[server].say channel, message

		sendMessageToAll: (messageArray) ->
			messageArray = [messageArray] if !_.isArray messageArray

			constructMessage = (messageToConstruct) ->
				_.map messageToConstruct, (messageItem) -> messageItem.message
				.join ' '

			message = constructMessage messageArray
			@broadcast message

		generateIdent: (server, username) ->
			return null if not username
			"#{server}##{username}"

		addUser: (ident) ->
			return if not ident
			#console.log "[client] adding #{ident}"
			@userIdentsList.push ident
			@userIdentsList = _.uniq @userIdentsList

			@IdleWrapper.api.add.player ident

		removeUser: (ident) ->
			return if not ident
			@userIdentsList = _.without @userIdentsList, ident
			#console.log "[client] removing #{ident}"

			@IdleWrapper.api.remove.player ident

		buildUserList: () =>
			#TODO this is called a lot of times on load for some reason
			#TODO flatten this so it's less indented
			for server, channels of @serverChannels
				for channel in channels
					bot = @serverBots[server]
					if bot.conn.chans[channel]
						chanUsers = bot.getUsers channel
						chanUsers = _.forEach chanUsers, (user) =>
							bot.userManager.getUsername {user: user, bot: bot}, (e, username) =>
								ident = @generateIdent server, username
								@addUser ident

		constructor: (moduleManager) ->
			super moduleManager

			@IdleWrapper = require("../../src/system/ExternalWrapper")()
			@loadIdle()

			@db = @newDatabase 'channels'

			randomFromArray = (array) ->
				array[Math.floor Math.random() * array.length]

			pickRandomPlayer = () =>
				randomFromArray @userIdentsList

			do () =>
				Q.when @db.databaseReady, (db) =>
					@db.find {active: true}, (e, docs) =>
						_.forEach docs, (doc) =>
							bot = BotManager.botHash[doc.server]
							@addServerChannel bot, doc.server, doc.channel
						@loadIdle true

			do () =>
				@interval = setInterval =>
					@IdleWrapper.api.game.nextAction pickRandomPlayer()
				, 1000

			do () =>
				watch idlePath, {}, () =>
					files = finder.from(idlePath).findFiles("*.coffee");

					_.forEach files, (file) ->
						delete require.cache[file]

					@loadIdle()

			@on "join", (bot, channel, sender) =>
				if bot.config.nick is sender
					#TODO +m the channel
					#TODO set topic
					@buildUserList() if not @users.length
					return

				bot.userManager.getUsername {user: sender, bot: bot}, (e,username) =>
					ident = @generateIdent bot.config.server, username
					@addUser ident
					@userIdents[@generateIdent bot.config.server,sender] = ident

			@on "part", (bot, channel, sender) =>
				bot.userManager.getUsername {user: sender, bot: bot}, (e,username) =>
					ident = @generateIdent bot.config.server, username
					@removeUser ident
					@userIdents[@generateIdent bot.config.server,sender] = ident

			@on "quit", (bot, sender) =>
				@removeUser @generateIdent bot.config.server, @userIdents[@generateIdent bot.config.server,sender]
				delete @userIdents[@generateIdent bot.config.server,sender]

			@on "nick", (bot, oldNick, newNick) =>
				@userIdents[@generateIdent bot.config.server,newNick] = @userIdents[@generateIdent bot.config.server,oldNick]
				delete @userIdents[@generateIdent bot.config.server,oldNick]

			@addRoute "idle-start", "idle.game.start", (origin, route) =>
				[channel, server] = [origin.channel, origin.bot.config.server]
				@db.update { channel: channel, server: server },
					{ channel: channel, server: server, active: true },
					{ upsert: true }

				@addServerChannel origin.bot, server, channel

				@reply origin, "Idletopia will exist in this channel."

			@addRoute "idle-stop", "idle.game.stop", (origin, route) =>
				[channel, server] = [origin.channel, origin.bot.config.server]
				@db.update { channel: channel, server: server },
					{ channel: channel, server: server, active: false },
					{ upsert: true }

				@removeServerChannel origin.bot, server, channel

				@reply origin, "Idletopia will vanish from this channel."

			@addRoute "idle-register :name", (origin, route) =>
				[bot, name] = [origin.bot, route.params.name]

				bot.userManager.getUsername origin, (e, username) =>
					if not username
						@reply origin, "You must be logged in to services play this game!"
						return

					identifier = @generateIdent origin.bot.config.server, username

					@IdleWrapper.api.register.player
						identifier: identifier
						name: name
					, null , (status) =>
						if not status.success
							@reply origin, "You're already registered a character to that ident!"

			@addRoute "idle-add event yesno \":question\" \":affirm\" \":deny\"", "idle.game.gm", (origin, route) =>
				[question, affirm, deny] = [route.params.question, route.params.affirm, route.params.deny]
				@IdleWrapper.api.add.yesno question, affirm, deny

			@addRoute "idle-add event :eventType \":question\"", "idle.game.gm", (origin, route) =>
				[eventType, question] = [route.params.eventType, route.params.question]
				if eventType not in ['blessXp', 'forsakeXp', 'blessGold', 'forsakeGold', 'blessItem', 'forsakeItem', 'findItem', 'party']
					@reply origin, "#{eventType} isn't a valid event type."
					return

				@IdleWrapper.api.add.static eventType, question

			@addRoute "idle-teleportloc :playerName :location", "idle.game.gm", (origin, route) =>
				[name, location] = [route.params.playerName, route.params.location]
				@IdleWrapper.api.game.teleport.singleLocation name, location

			@addRoute "idle-teleport :playerName :map :x,:y", "idle.game.gm", (origin, route) =>
				[name, map, x, y] = [route.params.playerName, route.params.map, route.params.x, route.params.y]
				x = parseInt x
				y = parseInt y
				@IdleWrapper.api.game.teleport.single name, map, x, y

			@addRoute "idle-massteleportloc :location", "idle.game.gm", (origin, route) =>
				[location] = [route.params.location]
				@IdleWrapper.api.game.teleport.massLocation location

			@addRoute "idle-massteleport :map :x,:y", "idle.game.gm", (origin, route) =>
				[map, x, y] = [route.params.map, route.params.x, route.params.y]
				x = parseInt x
				y = parseInt y
				@IdleWrapper.api.game.teleport.mass map, x, y,

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

		destroy: ->
			clearInterval @interval
			super()

	IdleModule
