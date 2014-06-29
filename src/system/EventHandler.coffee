Chance = require "chance"
chance = new Chance()

_ = require "underscore"

MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

class EventHandler

  constructor: (@game) ->

  doEvent: (eventType, player, callback) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      return if not event
      switch eventType
        when 'yesno'
          @doYesNo event, player, callback
        when 'blessXp', 'forsakeXp'
          @doXp event, player, callback
        when 'blessGold', 'forsakeGold'
          @doGold event, player, callback
        when 'blessItem', 'forsakeItem'
          @doItem event, player, callback

  doYesNo: (event, player, callback) ->
    if chance.bool {likelihood: player.calculateYesPercent()}
      (@game.broadcast MessageCreator.genericMessage @doStringReplace event.y, player) if event.y
      callback true
    else
      (@game.broadcast MessageCreator.genericMessage @doStringReplace event.n, player) if event.n
      callback false

  doXp: (event, player, callback) ->
    boost = 0

    if (chance.bool {likelihood: player.calculateYesPercent()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor player.xp.maximum / Constants.eventEffects[event.type].percent

    extra =
      xp: Math.abs boost

    player.gainXp boost

    @game.broadcast MessageCreator.genericMessage @doStringReplace event.remark, player, extra
    callback()

  doGold: (event, player, callback) ->
    boost = Constants.eventEffects[event.type].amount

    extra =
      gold: Math.abs boost

    player.gainGold boost

    @game.broadcast MessageCreator.genericMessage @doStringReplace event.remark, player, extra
    callback()

  doItem: (event, player, callback) ->
    item = (_.shuffle player.equipment)[0]
    stat = (_.shuffle (_.reject (_.keys item), (key) -> key is "name"))[0]

    val = item[stat] ? 0

    boost = 0

    if (chance.bool {likelihood: player.calculateYesPercent()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor val / Constants.eventEffects[event.type].percent

    extra =
      item: item.name

    start = val
    end = val+boost

    item[stat] = end

    string = @doStringReplace event.remark, player, extra
    string += " [#{stat} #{start} -> #{end}]"

    @game.broadcast MessageCreator.genericMessage string
    callback()

  doStringReplace: (string, player, extra = null) ->
    gender = player.getGender()
    string
      .split('%player').join player.name
      .split('%hisher').join @getGenderPronoun gender, '%hisher'
      .split('%himher').join @getGenderPronoun gender, '%himher'
      .split('%hishers').join @getGenderPronoun gender, '%hishers'
      .split('%she').join @getGenderPronoun gender, '%she'
      .split('%item').join extra?.item
      .split('%xp').join extra?.xp
      .split('%gold').join extra?.gold

  getGenderPronoun: (gender, replace) ->
    switch replace
      when '%hisher'
        if gender is 'male' then 'his'
        else if gender is 'female' then 'her'
        else 'their'

      when '%hishers'
        if gender is 'male' then 'his'
        else if gender is 'female' then 'hers'
        else 'theirs'

      when '%himher'
        if gender is 'male' then 'him'
        else if gender is 'female' then 'her'
        else 'theirs'

      when '%she'
        if gender is 'male' then 'he'
        else if gender is 'female' then 'she'
        else 'it'

module.exports = exports = EventHandler