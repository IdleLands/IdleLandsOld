
Constants = require "./Constants"

_ = require "underscore"

requireDir = require "require-dir"

cataclysms = requireDir "../event/cataclysms"

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

    callback true

  doBattle: ->
    @game.componentDatabase.getRandomEvent 'battle', (e, event = {}) =>
      event.player = @game.playerManager.randomPlayer()
      @game.startBattle [], event

  doCataclysm: ->
    cata = new cataclysms[_.sample _.keys cataclysms] @game
    do cata.go

module.exports = exports = GlobalEventHandler
