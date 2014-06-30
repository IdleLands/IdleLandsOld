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
        when 'findItem'
          @doFindItem event, player, callback

  doYesNo: (event, player, callback) ->
    player.emit "yesno"
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
    goldTiers = Constants.eventEffects[event.type].amount
    curGold = player.gold.getValue()

    boost = 0
    console.log 'test'
    for i in [0...goldTiers.length]
      if curGold < Math.abs goldTiers[i]
        highVal = if not goldTiers[i-1] then 100 else goldTiers[i-1]
        lowVal = if not goldTiers[i] then 1 else goldTiers[i]
        min = Math.min highVal, lowVal, 0
        max = Math.max highVal, lowVal
        boost = chance.integer {min: min, max: max}
        break

    return if not boost

    extra =
      gold: Math.abs boost

    return if player.gold.getValue() is 0

    player.gainGold boost

    @game.broadcast MessageCreator.genericMessage @doStringReplace event.remark, player, extra
    callback()

  doItem: (event, player, callback) ->
    item = (_.sample player.equipment)
    stat = (_.sample (_.reject (_.keys item), (key) -> key is "name"))

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

    return if start is end

    item[stat] = end

    string = @doStringReplace event.remark, player, extra
    string += " [#{stat} #{start} -> #{end}]"

    @game.broadcast MessageCreator.genericMessage string
    callback()

  doFindItem: (event, player, callback) ->
    item = @game.equipmentGenerator.generateItem()
    myItem = _.findWhere player.equipment, {type: item.type}
    return if not myItem
    score = item.score()
    myScore = myItem.score()

    if score > myScore
      player.equipment = _.without player.equipment, myItem
      player.equipment.push item

      extra =
        item: item.name

      @game.broadcast MessageCreator.genericMessage @doStringReplace event.remark, player, extra

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