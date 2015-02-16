
_ = require "lodash"
_.str = require "underscore.string"
MessageCreator = require "../system/handlers/MessageCreator"
chance = new (require "chance")()

class Party
  constructor: (@game, players) ->
    players = [players] if not _.isArray players
    @players = []
    @name = @pickPartyName()
    if (not players) or players.length < 1
      @disband()
      return
    @recruit players
    @addGlobally()

  score: ->
    _.reduce @players, ((prev, player) -> prev + player.calc.totalItemScore()), 0

  level: ->
    (_.reduce @players, ((prev, player) -> prev + player.level.getValue()), 0) / @players.length

  getPartyName: ->
    if @players.length > 1 then @name else @players[0].name

  pickPartyName: ->
    @game.componentDatabase.generatePartyName()

  prepareForBattle: ->
    _.each @players, (player) =>
      pet = @game.petManager.getActivePetFor player
      return if not pet
      @addPlayer pet if pet.tryToJoinCombat()

    if chance.bool({likelihood: 1})
      deity = _.sample @game.componentDatabase.generatorCache.deity
      deityMon = @game.monsterGenerator.generateScalableMonster @, @score(), deity
      deityMon.isPet = yes
      @addPlayer deityMon

  finishAfterBattle: ->
    _(@players)
      .filter (player) -> player.isPet
      .each (pet) => @playerLeave pet, yes

  shouldDisband: (basePercent = 0) ->
    chance.bool likelihood: Math.max 0, Math.min 100, basePercent+(_.reduce @players, ((prev, player) -> prev + player.calc.partyLeavePercent()), 0)/@players.length

  addGlobally: ->
    if not @game.parties
      @game.parties = []

    @game.parties.push @

  addPlayer: (player) ->
    @recruit [player]

  recruit: (players) ->
    _.forEach players, (player) =>
      return if player in @players

      ##TAG:EVENT_EVENT: party.join | none | Emitted when a player joins a party
      player.emit "player.party.join"
      player.party = @
      player.partyName = @name
      @players.push player

  playerLeave: (player, forced = no) ->
    @players = _.without @players, player

    ##TAG:EVENT_EVENT: party.leave | none | Emitted when a player leaves a party
    player.emit "player.party.leave", player, @
    player.partyName = ''

    # forced = yes means disband() called this
    if not forced

      message = ''

      if @players.length <= 1
        message = "<player.name>#{player.getName()}</player.name> has disbanded <event.partyName>#{@name}</event.partyName>."
      else
        message = "<player.name>#{player.getName()}</player.name> has left <event.partyName>#{@name}</event.partyName>."

      @game.eventHandler.broadcastEvent {message: message, player: player, type: 'party'}

    @disband() if @players.length <= 1

    player.party = null

  disband: ->
    @game.parties = _.without @game.parties, @
    _.forEach @players, (player) => @playerLeave player, yes

module.exports = exports = Party
