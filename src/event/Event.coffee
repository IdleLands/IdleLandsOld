
chance = new (require "chance")()
MessageCreator = require "../system/handlers/MessageCreator"
Constants = require "../system/utilities/Constants"

_ = require "lodash"

class Event
  constructor: (@game, @event, @player) ->

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

  grantRapportForAllPlayers: (party, bonus) ->
    _.each party.players, (player) ->
      _.each party.players, (playerTwo) ->
        return if player is playerTwo
        return if playerTwo.isMonster

        player.modifyRelationshipWith playerTwo.name, bonus

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

    boost

  ignoreKeys: ['_calcScore', 'enchantLevel']

  specialStats: Event::specialStats = [
    'absolute'
    'aegis'
    'crit'
    'dance'
    'deadeye'
    'defense'
    'glowing'
    'haste'
    'lethal'
    'poison'
    'power'
    'prone'
    'offense'
    'royal'
    'shatter'
    'silver'
    'sturdy'
    'vampire'
    'venom'
    'vorpal'
    'startle'
    'fear'
    'parry'
    'punish'
    'darkside'
    'forsaken'
    'limitless'
    'sacred'
    'sentimentality'
  ]

  t0: ['int', 'str', 'dex', 'con', 'wis', 'agi']
  t1: ['intPercent', 'strPercent', 'conPercent', 'wisPercent', 'agiPercent']
  t2: ['gold', 'xp', 'hp', 'mp']
  t3: ['goldPercent', 'xpPercent', 'hpPercent', 'mpPercent', 'luck']
  t4: ['luckPercent']

  allValidStats: -> @t0.concat @t1.concat @t2.concat @t3.concat @t4

  pickStatPresentOnItem: (item, base = @allValidStats()) ->
    nonZeroStats = _.reject (_.keys item), (stat) -> item[stat] is 0 or _.isNaN item[stat]
    statsInBoth = _.intersection base, nonZeroStats
    _.sample statsInBoth

  pickStatNotPresentOnItem: (item, base = @allValidStats()) ->
    zeroStats = _.filter (_.keys item), (stat) -> item[stat] is 0
    statsMissing = _.intersection base, zeroStats
    _.sample statsMissing

  pickSpecialNotPresentOnItem: (item, base = @specialStats) ->
    statsMissing = _.reject @specialStats, (stat) -> item[stat]?
    _.sample statsMissing

  pickValidItem: (player, isEnchant = no) ->
    items = player.equipment

    goodItems = _.reject items, (item) -> item.type in ["providence"] or item.name is "empty"

    forsaken = _.filter goodItems, (item) -> item.forsaken

    return (_.sample forsaken) if forsaken.length > 0

    nonSacred = _.reject goodItems, (item) -> item.sacred

    if isEnchant then nonSacred = _.reject nonSacred, (item) -> item.enchantLevel >= Constants.defaults.game.maxEnchantLevel and not item.limitless

    _.sample nonSacred

  pickBlessStat: (item) ->
    chances = [1, 5, 10, 20, 100]
    keys = [@t4, @t3, @t2, @t1, @t0]
    validKeysToChoose = _.compact _.map keys, (keyList) =>
      @pickStatPresentOnItem item, keyList

    return '' if validKeysToChoose.length is 0

    chances = chances[-validKeysToChoose.length..]

    retStat = ''
    for i in [0..validKeysToChoose.length]
      if chance.bool {likelihood: chances[i]}
        retStat = validKeysToChoose[i]
        break

    retStat

module.exports = exports = Event