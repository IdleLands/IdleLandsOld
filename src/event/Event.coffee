
chance = new (require "chance")()
MessageCreator = require "../system/MessageCreator"
Constants = require "../system/Constants"

_ = require "underscore"

class Event
  constructor: (@game, @event, @player) ->

  # sendMessage = no implies that you're forwarding the original message to multiple people
  broadcastEvent: (options) ->
    {message, player, extra, sendMessage, type, link} = options
    sendMessage = yes if _.isUndefined sendMessage
    extra = {} if not extra

    if sendMessage
      message = MessageCreator.doStringReplace message, player, extra
      @game.broadcast MessageCreator.genericMessage message

    stripped = MessageCreator._replaceMessageColors message

    if link
      player.pushbulletSend extra.linkTitle, link
    else player.pushbulletSend stripped
    @addEventToDb stripped, player, type, extra

    message

  addEventToDb: (message, player, type, extra = {}) ->

    event =
      createdAt: new Date()
      player: player.name
      message: message
      type: type
      extra: extra

    player.recentEvents = [] if not player.recentEvents
    player.recentEvents.push event
    player.recentEvents.shift() if player.recentEvents.length > Constants.defaults.player.maxRecentEvents

    @game.eventHandler.playerEventsDb.insert event, ->

  calcXpEventGain: (eventType, player) ->
    if (chance.bool {likelihood: player.calculateYesPercent()})
      percent = Constants.eventEffects[eventType].fail
      if player.level.getValue() < 100 then Math.floor player.xp.maximum * (percent/100) else 1

    else
      min = Constants.eventEffects[eventType].minPercent
      max = Constants.eventEffects[eventType].maxPercent
      flux = Constants.eventEffects[eventType].flux
      step = player.level.maximum / (max - min)
      steps = Math.floor ((player.level.maximum - player.level.getValue()) / step)

      fluxed = chance.floating {min: -flux, max: flux, fixed: 3}

      percent = min + steps + fluxed

      if player.level.getValue() < 100 then Math.floor player.xp.maximum * (percent/100) else player.level.getValue()

  calcGoldEventGain: (eventType, player) ->

    goldTiers = Constants.eventEffects[eventType].amount
    curGold = player.gold.getValue()

    boost = 0
    for i in [0...goldTiers.length]
      if curGold < Math.abs goldTiers[i]
        highVal = if not goldTiers[i-1] then 100 else goldTiers[i-1]
        lowVal = if not goldTiers[i] then 1 else goldTiers[i]

        min = Math.min highVal, lowVal
        max = Math.max highVal, lowVal
        boost = chance.integer {min: min, max: max}
        break

    if not boost
      val = _.last goldTiers
      min = Math.min val, 0
      max = Math.max val, 1
      boost = chance.integer min: min, max: max

module.exports = exports = Event