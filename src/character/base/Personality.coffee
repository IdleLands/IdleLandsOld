
requireDir = require "require-dir"
personalities = requireDir "../personalities"

class Personality

  constructor: (player) ->

  unbind: (player) ->

Personality::isPhysical = (test) ->
  test in ['Fighter', 'Generalist']

Personality::isMagical = (test) ->
  test in ['Mage', 'Cleric']

Personality::isMedic = (test) ->
  test in ['Cleric']

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new personalities[personality] forWho

module.exports = exports = Personality