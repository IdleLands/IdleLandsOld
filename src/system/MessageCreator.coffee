
class MessageCreator

  genericMessage = (message) ->
    [{type: 'generic', message: message}]

  @generateMessage: (message) ->
    genericMessage message

  @genericMessage: genericMessage

  #more types: combat, health, mana, special, announcement, event.gold, event.item, event.xp

module.exports = exports = MessageCreator