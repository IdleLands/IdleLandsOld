
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

  @doStringReplace: (string, player, extra = null) ->
    gender = player.getGender()
    string
      .split('%player').join player.name
      .split('%hisher').join getGenderPronoun gender, '%hisher'
      .split('%himher').join getGenderPronoun gender, '%himher'
      .split('%hishers').join getGenderPronoun gender, '%hishers'
      .split('%she').join getGenderPronoun gender, '%she'
      .split('%item').join extra?.item
      .split('%xp').join extra?.xp
      .split('%gold').join extra?.gold
      .split('%partyName').join extra?.partyName
      .split('%party').join extra?.party

  #more types: combat, health, mana, special, announcement, event.gold, event.item, event.xp

module.exports = exports = MessageCreator