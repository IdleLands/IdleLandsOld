
_ = require "lodash"

class TimedEffect
  name: "THIS EFFECT HAS NO NAME"

  apply: (affected = [], @duration = 0) ->

    affected = [affected] if not _.isArray affected

    _.each affected, (player) =>

      if not player
        @game.errorHandler.captureMessage "INVALID PLAYER for #{@baseName}: ", player
        return

      duration  = @duration?(player) ? @duration

      player.buffsAffectedBy = [] if not player.buffsAffectedBy or not _.isArray player.buffsAffectedBy

      oldBuff = _.findWhere player.buffsAffectedBy, baseName: @baseName

      if oldBuff
        oldBuff.refresh duration
      else
        @refresh duration
        player.buffsAffectedBy.push _.omit @, 'game'

  refresh: (duration) ->
    seconds = (duration.years ?= 0) * 31536000 + # 365 days
      (duration.months ?= 0) * 2592000 + # 30 days
      (duration.days ?= 0) * 86700 +
      (duration.hours ?= 0) * 3600 +
      (duration.minutes ?= 0) * 60 +
      (duration.seconds ?= 0)
    if not @expire
      @expire = Date.now() + seconds*1000
    else @expire = @expire + seconds*1000

  constructor: ->
    @baseName = @name

module.exports = exports = TimedEffect