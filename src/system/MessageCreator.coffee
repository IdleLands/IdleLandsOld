
_ = require "underscore"
_.str = require "underscore.string"

class MessageCreator

  defaultReplaceFunction = (msg) -> msg

  defaultColorMap =
    colorMap =
      "player.name":                defaultReplaceFunction
      "event.partyName":            defaultReplaceFunction
      "event.partyMembers":         defaultReplaceFunction
      "event.player":               defaultReplaceFunction
      "event.damage":               defaultReplaceFunction
      "event.gold":                 defaultReplaceFunction
      "event.realGold":             defaultReplaceFunction
      "event.xp":                   defaultReplaceFunction
      "event.realXp":               defaultReplaceFunction
      "event.percentXp":            defaultReplaceFunction
      "event.item.newbie":          defaultReplaceFunction
      "event.item.Normal":          defaultReplaceFunction
      "event.item.basic":           defaultReplaceFunction
      "event.item.pro":             defaultReplaceFunction
      "event.item.idle":            defaultReplaceFunction
      "event.item.godly":           defaultReplaceFunction
      "event.item.custom":          defaultReplaceFunction
      "event.finditem.scoreboost":  defaultReplaceFunction
      "event.finditem.perceived":   defaultReplaceFunction
      "event.finditem.real":        defaultReplaceFunction
      "event.blessItem.stat":       defaultReplaceFunction
      "event.blessItem.value":      defaultReplaceFunction
      "event.flip.stat":            defaultReplaceFunction
      "event.flip.value":           defaultReplaceFunction
      "event.enchant.boost":        defaultReplaceFunction
      "event.enchant.stat":         defaultReplaceFunction
      "event.tinker.boost":         defaultReplaceFunction
      "event.tinker.stat":          defaultReplaceFunction
      "event.transfer.destination": defaultReplaceFunction
      "event.transfer.from":        defaultReplaceFunction
      "player.class":               defaultReplaceFunction
      "player.level":               defaultReplaceFunction
      "stats.hp":                   defaultReplaceFunction
      "stats.mp":                   defaultReplaceFunction
      "stats.sp":                   defaultReplaceFunction
      "damage.hp":                  defaultReplaceFunction
      "damage.mp":                  defaultReplaceFunction
      "spell.turns":                defaultReplaceFunction
      "spell.spellName":            defaultReplaceFunction
      "event.casterName":           defaultReplaceFunction
      "event.spellName":            defaultReplaceFunction
      "event.targetName":           defaultReplaceFunction
      "event.achievement":          defaultReplaceFunction
      "event.guildName":            defaultReplaceFunction

  @replaceMessageColors: (message) ->
    @_replaceMessageColors message, _.defaults (@colorMap or {}), defaultColorMap

  @_replaceMessageColors: (message, map = defaultColorMap) ->

    for search, replaceFunc of map
      regexp = new RegExp "(<#{search}>)([\\s\\S]*?)(<\\/#{search}>)", "g"
      message = message.replace regexp, (match, p1, p2) ->
        replaceFunc p2

    message

  @genericMessage: (message) ->
    return if not message
    @replaceMessageColors message

  @registerMessageMap: (@colorMap) ->
    console.log "Registered color map."

  getGenderPronoun = (gender, replace) ->
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
        else 'them'

      when '%she'
        if gender is 'male' then 'he'
        else if gender is 'female' then 'she'
        else 'they'

  #more types: combat, health, mana, special, announcement, event.gold, event.item, event.xp

  @doStringReplace: (string, player, extra = {}) ->
    gender = player.getGender()
    string = _.str.clean string

    (string = string.split("%#{key}").join (if key is "item" then val else "<event.#{key}>#{val}</event.#{key}>")) for key, val of extra

    string
      .split('%player').join "<player.name>#{player.name}</player.name>"
      .split('%hishers').join getGenderPronoun gender, '%hishers'
      .split('%hisher').join getGenderPronoun gender, '%hisher'
      .split('%himher').join getGenderPronoun gender, '%himher'
      .split('%she').join getGenderPronoun gender, '%she'
      .split('%heshe').join getGenderPronoun gender, '%she'

      .split('%Hishers').join _.str.capitalize getGenderPronoun gender, '%hishers'
      .split('%Hisher').join _.str.capitalize getGenderPronoun gender, '%hisher'
      .split('%Himher').join _.str.capitalize getGenderPronoun gender, '%himher'
      .split('%She').join _.str.capitalize getGenderPronoun gender, '%she'
      .split('%Heshe').join _.str.capitalize getGenderPronoun gender, '%she'

module.exports = exports = MessageCreator
