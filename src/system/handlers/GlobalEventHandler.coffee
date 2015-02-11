
Constants = require "./../utilities/Constants"

_ = require "lodash"

requireDir = require "require-dir"

cataclysms = requireDir "../../event/cataclysms"
MessageCreator = require "./MessageCreator"

class GlobalEventHandler

  constructor: (@game) ->
    @initializeEventTimers()

  initializeEventTimers: ->
    timers = Constants.globalEventTimers
    _.each timers, (timer) =>
      setInterval (@doEvent.bind @,timer.type), timer.duration*1000

  doEvent: (event = Constants.pickRandomGlobalEvent(), callback = ->) ->
    switch event
      when 'battle'
        do @doBattle

      when 'cataclysm'
        do @doCataclysm

      when 'advanceDate'
        do @doAdvanceDate

      when 'towncrier'
        do @doAdvertisement

    callback true

  doBattle: ->
    @game.componentDatabase.getRandomEvent 'battle', {}, (e, event = {}) =>
      event.player = @game.playerManager.randomPlayer()
      @game.battleManager.startBattle [], event

  doCataclysm: ->
    cata = new cataclysms[_.sample _.keys cataclysms] @game
    do cata.go

  doAdvanceDate: ->
    @game.calendar.advance 1
    @game.broadcast ">>> CALENDAR: It is now the #{@game.calendar.getDateName()}."

  doAdvertisement: ->
    @game.componentDatabase.getRandomEvent 'towncrier', {blast: 1, expiredOn: {$exists: no}}, (e, event = {}) =>
      return unless event._id

      # Explanation of "6"
      # It is assumed that some players have multiple characters, so we don't want to count duplicates
      # It is assumed that few people watch IRC (and there is no way to know for sure), so we take off a few more
      # This is not broadcast to WebFE, so we have to cut off some players to account for that loss as well
      numPlayers = @game.playerManager.players.length / 6
      @game.componentDatabase.lowerAdViewCount event._id, numPlayers

      linkText = if event.link then "[ #{event.link} ] " else ""
      @game.broadcast MessageCreator.genericMessage ">>> TOWN CRIER: #{linkText}#{event.message}"

module.exports = exports = GlobalEventHandler
