
requireDir = require "require-dir"
personalities = requireDir "../personalities"

class Personality

  constructor: (player) ->

  unbind: (player) ->

Personality::isPhysical = (test) ->
  test in ['Fighter', 'Generalist', 'Barbarian', 'Rogue', 'Jester']

Personality::isMagical = (test) ->
  test in ['Mage', 'Cleric', 'Bard']

Personality::isMedic = (test) ->
  test in ['Cleric']

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new personalities[personality] forWho

module.exports = exports = Personality