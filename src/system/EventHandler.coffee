

class EventHandler

  constructor: (@game) ->

  doEvent: (eventType, player) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) ->
      console.log event,e

module.exports = exports = EventHandler