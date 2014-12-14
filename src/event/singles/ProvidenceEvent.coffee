
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

  generateFate: ->
    base =
      name: @game.componentDatabase.generateProvidenceName()
      type: "providence"  #end of the alphabet, slotwise
      itemClass: "basic"

    _.each @allValidStats(), (stat) ->
      base[stat] = chance.integer {min: -300, max: 200} if (stat.indexOf("Percent") is -1)   and chance.bool {likelihood: 50}
      base[stat] = chance.integer {min: -60, max: 40}   if (stat.indexOf("Percent") isnt -1) and chance.bool {likelihood: 25}

    _.each @specialStats, (stat) ->
      base[stat] = chance.integer {min: -3, max: 2} if chance.bool {likelihood: 25}

    new Equipment base

  go: ->
    message = "#{@event.remark}"

    availableClasses = _.keys @player.statistics?['calculated class changes'] or []
    availablePersonalities = _(@player.achievements)
      .filter (achievement) -> achievement.type is "personality"
      .map (achievement) -> achievement._personality
      .value()

    xpMod = chance.integer {min: -@player.xp.maximum, max: @player.xp.maximum}
    levelMod = chance.integer {min: -3, max: 2}
    gender = _.sample ['male', 'female', 'glowcloud', 'not a bear', 'astroentity', 'secret', 'other']
    goldMod = chance.integer {min: -30000, max: 20000}
    classMod = _.sample availableClasses
    numPersonalities = chance.integer {min: 0, max: availablePersonalities.length}
    personalityMod = _.sample availablePersonalities, numPersonalities

    if xpMod and chance.bool {likelihood: 60}
      @player.xp.add xpMod
      message = "#{message} #{if xpMod > 0 then 'Gained' else 'Lost'} #{Math.abs xpMod} xp!"

    else if levelMod and chance.bool {likelihood: 35}
      @player.level.add levelMod
      @player.resetMaxXp()
      message = "#{message} #{if levelMod > 0 then 'Gained' else 'Lost'} #{Math.abs levelMod} levels!"

    if @player.getGender() isnt gender and (chance.bool {likelihood: 80})
      @player.gender = gender
      message = "#{message} Gender is now '#{gender}'!"

    if goldMod and (chance.bool {likelihood: 50})
      @player.gold.add goldMod
      message = "#{message} #{if goldMod > 0 then 'Found' else 'Lost'} #{Math.abs goldMod} gold!"

    if classMod and @professionName isnt classMod and (chance.bool {likelihood: 15})
      @player.changeProfession classMod, yes
      message = "#{message} Changed class to #{classMod}!"

    if (chance.bool {likelihood: 25})
      @player.personalityStrings = personalityMod
      @player.rebuildPersonalityList()
      message = "#{message} Personality shift!"

    oldFate = _.findWhere @player.equipment, {type: "providence"}

    if oldFate and chance.bool {likelihood: 20}
      message = "#{message} Providence was cleared!"
      @player.equipment = _.without @player.equipment, oldFate

    else if not oldFate and chance.bool {likelihood: 75}
      message = "#{message} Gained a new Providence!"
      @player.equipment.push @generateFate()

    @game.eventHandler.broadcastEvent {message: message, player: @player, type: 'item-switcheroo'}

    @player.emit "event.providence", @player

module.exports = exports = ProvidenceEvent