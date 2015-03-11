
Event = require "../Event"
Equipment = require "../../item/Equipment"
_ = require "lodash"
Constants = require "../../system/utilities/Constants"
chance = new (require "chance")()

`/**
 * This event handles both the enchant and tinker aliases, which add new stats to an item.
 *
 * @name Enchant
 * @category Player
 * @package Events
 */`
class EnchantEvent extends Event

  getBlowupItem: (item, enchantLevel) ->
    r = (div) ->  Math.floor (chance.integer {min: -enchantLevel*10, max: enchantLevel*10})/div
    stats = {str: (r 2), dex: (r 2), con: (r 3), int: (r 0.5), wis: (r 0.3), agi: (r 1), luck: (r -1)}
    stats.type = item.type

    junks = [
      "blown up pile of junk"
      "pile of mystic dust"
      "dusting of mystic ash"
      "ball of mystic ooze"
      "mystical broken shards"
      "chunk of old soul"
      "handful of flux capacitor innards"
      "broken #{stats.type}"
    ]

    stats.name = _.sample junks
    new Equipment stats

  getStatForItem: (item) ->
    if @event.type is 'enchant' then [@pickStatNotPresentOnItem(item), 10] else [@pickSpecialNotPresentOnItem(item), 1]

  doNormalEnchant: (item) ->

    return no if item.enchantLevel >= Constants.defaults.game.maxEnchantLevel and not item.limitless

    [stat, boost] = @getStatForItem item
    
    return no unless stat

    item[stat] = boost

    "#{@event.remark} [<event.enchant.stat>#{stat} = #{boost}</event.enchant.stat> | <event.enchant.boost>+#{item.enchantLevel} -> +#{++item.enchantLevel}</event.enchant.boost>]"
    
  doGuildEnchant: (item) ->

    guild = @player.getGuild()
    return no unless guild

    #the world may never know...
    @event.type = _.sample ['tinker', 'enchant']
    enchantressLevel = @player.getGuildBuildingLevel "Enchantress"
    enchantressName = guild.buildingProps?.Enchantress?.Name or chance.name {gender: "female"}

    @event.remark = "%player has met with #{enchantressName}, the local guild enchantress for \"#{guild.name}!\""

    maxEnchant = Math.floor enchantressLevel/10
    maxSafeEnchant = maxEnchant - 2

    currentLevel = item.enchantLevel
    nextLevel = currentLevel+1

    isUnsafe = currentLevel+1 > maxSafeEnchant

    # you gotta opt in to potentially blow up items. I'm not that mean.
    shouldDoUnsafeEnchant = guild.buildingProps?.Enchantress?.AttemptEnchant is "Yes"
    notBlowupChance = if isUnsafe then 100 - (5 * (20 - enchantressLevel%20)) else 100
    
    [stat, boost] = @getStatForItem item
    
    return no unless stat
    
    item[stat] = boost

    if isUnsafe and not shouldDoUnsafeEnchant
      return "#{@event.remark} Unfortunately, enchanting to +#{nextLevel} was too unsafe to attempt!"

    cost = nextLevel*10000
    if @player.gold.getValue() < cost
      return "#{@event.remark} Unfortunately, %player lacks the funds to get a +#{nextLevel} enchantment!"

    @player.gold.sub cost

    if chance.bool {likelihood: notBlowupChance}
      base = "#{@event.remark} Thankfully, %player managed to get a successful +#{++item.enchantLevel} enchantment for %hisher newly %item!"
      return "#{base} [<event.enchant.stat>#{stat} = #{boost}</event.enchant.stat> | <event.enchant.boost>+#{item.enchantLevel} -> +#{++item.enchantLevel}</event.enchant.boost>]"
 

    else
      blownItem = @getBlowupItem item, nextLevel
      @player.equipment = _.without @player.equipment, item
      @player.equipment.push blownItem
      return "#{@event.remark} Sadly, %player's %item was reduced to a #{blownItem.getName()} while attempting a +#{nextLevel} enchantment."

  go: ->
    item = @pickValidItem @player, yes
    return unless item

    item.enchantLevel = 0 if not item.enchantLevel or _.isNaN item.enchantLevel

    message = if @isGuild then @doGuildEnchant item else @doNormalEnchant item
    return unless message

    extra =
      ##TAG:EVENTVAR_SIMPLE: %item | the name of the item affected (only applies to events that involve items)
      item: "<event.item.#{item.itemClass}>#{item.getName()}</event.item.#{item.itemClass}>"

    @player.permanentAchievements.plus100 = yes if 100 <= @player.calc.stat 'enchantLevel'

    @game.eventHandler.broadcastEvent {message: message, player: @player, extra: extra, type: 'item-enchant'}

    ##TAG:EVENT_EVENT: tinker | player, item, newEnchantLevel | Emitted when a player has a tinker event happen
    ##TAG:EVENT_EVENT: enchant | player, item, newEnchantLevel | Emitted when a player has an enchant event happen
    @player.emit "event.#{@event.type}", @player, item, item.enchantLevel

module.exports = exports = EnchantEvent
