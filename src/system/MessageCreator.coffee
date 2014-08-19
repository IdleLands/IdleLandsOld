
_ = {}
_.str = require "underscore.string"

class MessageCreator

  genericMessage = (message) ->
    return if not message
    [{type: 'generic', message: message}]

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
        else 'theirs'

      when '%she'
        if gender is 'male' then 'he'
        else if gender is 'female' then 'she'
        else 'it'

  @generateMessage: (message) ->
    genericMessage message

  @genericMessage: genericMessage

  #more types: combat, health, mana, special, announcement, event.gold, event.item, event.xp

  @doStringReplace: (string, player, extra = null) ->
    gender = player.getGender()
    string = _.str.clean string
    string
      .split('%player').join player.name
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

      .split('%item').join extra?.item
      .split('%xpp').join extra?.xpp
      .split('%xpr').join extra?.xpr
      .split('%xp').join extra?.xp
      .split('%goldr').join extra?.goldr
      .split('%gold').join extra?.gold
      .split('%partyName').join extra?.partyName
      .split('%party').join extra?.party

      .split('%damage').join extra?.damage

module.exports = exports = MessageCreator
