
requireDir = require "require-dir"
personalities = requireDir "../personalities"
MessageCreator = require "../../system/MessageCreator"

class Personality

  constructor: (player) ->

  unbind: (player) ->

  broadcastMessage: (player, message) ->
    player.playerManager.game.broadcast MessageCreator.genericMessage message

Personality::isPhysical = (test) ->
  test in ['Fighter', 'Generalist', 'Barbarian', 'Rogue', 'Jester']

Personality::isMagical = (test) ->
  test in ['Mage', 'Cleric', 'Bard', 'SandwichArtist']

Personality::isMedic = (test) ->
  test in ['Cleric', 'SandwichArtist']

Personality::isDPS = (test) ->
  test in ['Mage', 'Thief']

Personality::isTank = (test) ->
  test in ['Fighter', 'Barbarian']

Personality::isSupport = (test) ->
  test in ['Bard', 'SandwichArtist']

Personality::allPersonalities = -> personalities

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new require("../personalities/ConsolationPrize")(forWho)
  new personalities[personality] forWho

module.exports = exports = Personality