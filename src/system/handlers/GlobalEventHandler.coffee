
Constants = require "./../utilities/Constants"

_ = require "lodash"

requireDir = require "require-dir"

allEvents = requireDir "../../event/globals"

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
        (new allEvents.PvPEvent @game).go()

      when 'cataclysm'
        (new allEvents.CataclysmEvent @game).go()

      when 'advanceDate'
        (new allEvents.CalendarEvent @game).go()

      when 'towncrier'
        (new allEvents.MassTownCrierEvent @game).go()

    callback true

module.exports = exports = GlobalEventHandler
