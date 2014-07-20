Chance = require "chance"
chance = new Chance()

_ = require "underscore"
_.str = require "underscore.string"

MessageCreator = require "./MessageCreator"
Constants = require "./Constants"

Party = require "../event/Party"

class EventHandler

  constructor: (@game) ->

  doEvent: (eventType, player, callback) ->
    @game.componentDatabase.getRandomEvent eventType, (e, event) =>
      console.error e if e
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
        when 'party'
          @doParty event, player, callback
        when 'battle'
          @doBattle event, player, callback
        when 'enchant'
          @doEnchant event, player, callback

  doYesNo: (event, player, callback) ->
    player.emit "yesno"
    if chance.bool {likelihood: player.calculateYesPercent()}
      (@game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.y, player) if event.y
      callback true
    else
      (@game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.n, player) if event.n
      callback false

  doXp: (event, player, callback) ->
    boost = 0

    if (chance.bool {likelihood: player.calculateYesPercent()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor player.xp.maximum / Constants.eventEffects[event.type].percent

    extra =
      xp: Math.abs boost
      xpr: boost
      xpp: +((boost/player.xp.maximum)*100).toFixed 3

    player.gainXp boost

    message = event.remark + " [%xprxp, ~%xpp%]"

    @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player, extra
    callback()

  doGold: (event, player, callback) ->
    goldTiers = Constants.eventEffects[event.type].amount
    curGold = player.gold.getValue()

    boost = 0
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
      goldr: boost

    player.gainGold boost

    message = event.remark + " [%goldr gold]"

    @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace message, player, extra
    callback()

  doItem: (event, player, callback) ->
    item = (_.sample player.equipment)
    stat = (_.sample (_.reject (_.keys item), (key) -> key in ["name", "type", "itemClass", "enchantLevel"] or item[key] is 0))

    val = item[stat] ? 0

    boost = 0

    if (chance.bool {likelihood: player.calc.eventFumble()})
      boost = Constants.eventEffects[event.type].amount
    else
      boost = Math.floor Math.abs(val) / Constants.eventEffects[event.type].percent

    extra =
      item: item.getName()

    start = val
    end = val+boost

    return if start is end

    item[stat] = end

    string = MessageCreator.doStringReplace event.remark, player, extra
    string += " [#{stat} #{start} -> #{end}]"

    @game.broadcast MessageCreator.genericMessage string
    callback()

  doFindItem: (event, player, callback) ->
    item = @game.equipmentGenerator.generateItem()
    myItem = _.findWhere player.equipment, {type: item.type}
    return if not myItem
    score = player.calc.itemScore item
    myScore = player.calc.itemScore myItem

    if score >= myScore and item.score() < player.itemFindRange()
      player.equipment = _.without player.equipment, myItem
      player.equipment.push item

      extra =
        item: item.getName()

      totalString = "#{event.remark} [#{myScore} -> #{score} | +#{score-myScore}]"

      @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace totalString, player, extra

    callback()

  doParty: (event, player, callback) ->
    return if player.party or @game.inBattle
    newParty = @game.createParty player
    return if not newParty?.name

    newPartyPlayers = _.without newParty.players, player

    extra =
      party: _.str.toSentence _.pluck newPartyPlayers, 'name'
      partyName: newParty.name

    @game.broadcast MessageCreator.genericMessage MessageCreator.doStringReplace event.remark, player, extra

    callback()

  doBattle: (event, player, callback) ->
    event.player = player
    @game.startBattle [], event

    callback()

  doEnchant: (event, player, callback) ->
    item = _.sample _.reject player.equipment, (item) -> item.enchantLevel >= Constants.defaults.game.maxEnchantLevel
    stat = (_.sample (_.reject (_.keys item), (key) -> key in ["name", "type", "itemClass", "enchantLevel"] or item[key] isnt 0))

    boost = 10

    extra =
      item: item.getName()

    item[stat] += boost

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    string = MessageCreator.doStringReplace event.remark, player, extra
    string += " [#{stat} = #{boost} | +#{item.enchantLevel} -> +#{++item.enchantLevel}]"

    @game.broadcast MessageCreator.genericMessage string
    callback()

module.exports = exports = EventHandler