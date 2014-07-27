
requireDir = require "require-dir"
personalities = requireDir "../personalities"

class Personality

  constructor: (player) ->

  unbind: (player) ->

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new personalities[personality] forWho

module.exports = exports = Personality