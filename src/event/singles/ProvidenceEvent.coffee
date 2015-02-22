
Event = require "../Event"
_ = require "lodash"
_.str = require "underscore.string"
chance = new (require "chance")()
Equipment = require "../../item/Equipment"

`/**
 * This event can be your best friend, or your worst enemy.
 *
 * @name providence
 * @category Player
 * @package Events
 */`
class ProvidenceEvent extends Event

  generateFate: (multiplier = 1, bigShift = 0, midShift = 0, smallShift = 0) ->
    base =
      name: @game.componentDatabase.generateProvidenceName()
      type: "providence"  #end of the alphabet, slotwise
      itemClass: "basic"

    _.each @allValidStats(), (stat) ->
      base[stat] = chance.integer {min: (Math.min -15, (-150+bigShift)*multiplier), max: (100+bigShift)*multiplier} if (stat.indexOf("Percent") is -1)   and chance.bool {likelihood: 50}
      base[stat] = chance.integer {min: (Math.min -3, (-30+midShift)*multiplier), max: (20+midShift)*multiplier}   if (stat.indexOf("Percent") isnt -1) and chance.bool {likelihood: 25}

    _.each @specialStats, (stat) ->
      base[stat] = chance.integer {min: (Math.min -1, (-3+smallShift)*multiplier), max: (2+smallShift)*multiplier} if chance.bool {likelihood: 25}

    new Equipment base

  probabilities:
    xpMod: 60
    levelMod: 15
    gender: 80
    goldMod: 50
    classMod: 15
    personalityMod: 25
    clearFate: 20
    newFate: 75

  getPossibleClasses: ->
    _.keys @player.statistics?['calculated class changes'] or []

  getPossiblePersonalities: ->
    _(@player.achievements)
    .filter (achievement) -> achievement.type is "personality"
    .map (achievement) -> achievement._personality
    .value()

  getPossibleGenders: ->
    ['male', 'female', 'glowcloud', 'not a bear', 'astroentity', 'secret', 'other']

  basics: (message, obj) ->

    {xpMod, levelMod, goldMod, classMod, personalityMod, gender} = obj

    if xpMod and @player.level.getValue() < 100 and chance.bool {likelihood: @probabilities.xpMod}
      @player.xp.add xpMod
      message = "#{message} #{if xpMod > 0 then 'Gained' else 'Lost'} #{Math.abs xpMod} xp!"

    else if levelMod and @player.level.getValue() < 100 and chance.bool {likelihood: @probabilities.levelMod}
      @player.level.add levelMod
      @player.resetMaxXp()
      message = "#{message} #{if levelMod > 0 then 'Gained' else 'Lost'} #{Math.abs levelMod} levels!"

    if @player.getGender() isnt gender and (chance.bool {likelihood: @probabilities.gender})
      @player.gender = gender
      message = "#{message} Gender is now '#{gender}'!"

    if goldMod and (chance.bool {likelihood: @probabilities.goldMod})
      @player.gainGold goldMod
      message = "#{message} #{if goldMod > 0 then 'Found' else 'Lost'} #{Math.abs goldMod} gold!"

    if classMod and @professionName isnt classMod and (chance.bool {likelihood: @probabilities.classMod})
      @player.changeProfession classMod, yes
      message = "#{message} Changed class to #{classMod}!"

    if (chance.bool {likelihood: @probabilities.personalityMod})
      @player.personalityStrings = personalityMod
      @player.rebuildPersonalityList()
      message = "#{message} Personality shift!"

    message

  doNormalProvidence: ->
    message = @event.remark

    xpMod = chance.integer {min: -@player.xp.maximum, max: @player.xp.maximum}
    levelMod = chance.integer {min: -3, max: 2}
    gender = _.sample @getPossibleGenders()
    goldMod = chance.integer {min: -30000, max: 20000}
    classMod = _.sample @getPossibleClasses()

    availablePersonalities = @getPossiblePersonalities()
    numPersonalities = chance.integer {min: 0, max: availablePersonalities.length}
    personalityMod = _.sample availablePersonalities, numPersonalities

    message = @basics message, {xpMod, levelMod, goldMod, classMod, personalityMod, gender}

    oldFate = _.findWhere @player.equipment, {type: "providence"}

    if oldFate and chance.bool {likelihood: @probabilities.clearFate}
      message = "#{message} Providence was cleared!"
      @player.equipment = _.without @player.equipment, oldFate

    else if not oldFate and chance.bool {likelihood: @probabilities.newFate}
      message = "#{message} Gained a new Providence!"
      @player.equipment.push @generateFate()

    message

  doGuildProvidence: ->
    guild = @player.getGuild()
    return no unless guild

    fortuneLevel = @player.getGuildBuildingLevel "FortuneTeller"
    fortuneName = guild.buildingProps?.FortuneTeller?.Name or chance.name {gender: "male"}

    getWithinBoundsIfLevelReqMet = (req, min, max, mult = 1, shift = 0) ->
      return 0 if fortuneLevel < req
      chance.integer {min: (min+shift)*mult, max: (max+shift)*mult}

    message = "%player has met with #{fortuneName}, the local guild fortune teller for \"#{guild.name}!\""

    # gender can always happen
    gender = _.sample @getPossibleGenders()

    # xpMod can always happen; every 10 levels is +10% more XP range
    xpMod = getWithinBoundsIfLevelReqMet 1, -@player.xp.maximum, @player.xp.maximum, (Math.floor fortuneLevel/10)*(1/10)

    # goldMod can happen at level 20
    goldMod = getWithinBoundsIfLevelReqMet 20, -6000, 4000, (Math.floor fortuneLevel/20), (Math.floor fortuneLevel/20)*1000

    # personalities require level 40
    availablePersonalities = @getPossiblePersonalities()
    personalitiesToChoose = if fortuneLevel >= 40 then availablePersonalities.length else 0
    numPersonalities = chance.integer {min: 0, max: personalitiesToChoose}
    personalityMod = _.sample availablePersonalities, numPersonalities

    # classMod requires level 60
    classMod = if fortuneLevel >= 60 then _.sample @getPossibleClasses() else ''

    # requires level 80; actually goes from -3 to 2, but we're abusing the shift param so it starts at +1 by default.
    levelMod = getWithinBoundsIfLevelReqMet 80, -4, 1, 1, Math.floor fortuneLevel/80

    message = @basics message, {xpMod, levelMod, goldMod, classMod, personalityMod, gender}

    oldFate = _.findWhere @player.equipment, {type: "providence"}

    # can always clear providences. I guess that's a nice thing to do.
    if oldFate and chance.bool {likelihood: @probabilities.clearFate}
      message = "#{message} Providence was cleared!"
      @player.equipment = _.without @player.equipment, oldFate

    # requires level 50
    else if not oldFate and fortuneLevel >= 50 and chance.bool {likelihood: @probabilities.newFate}
      message = "#{message} Gained a new Providence!"

      provLevel = Math.floor fortuneLevel/50
      @player.equipment.push @generateFate provLevel/2, 15*provLevel, 3*provLevel, 1*provLevel

    message

  go: ->
    message = if @isGuild then @doGuildProvidence() else @doNormalProvidence()
    return unless message

    @game.eventHandler.broadcastEvent {message: message, player: @player, type: 'item-switcheroo'}

    ##TAG:EVENT_EVENT: providence | player | Emitted when a player gets really unlucky
    @player.emit "event.providence", @player

module.exports = exports = ProvidenceEvent
