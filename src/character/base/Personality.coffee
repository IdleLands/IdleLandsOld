
requireDir = require "require-dir"
personalities = requireDir "../personalities"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"

class Personality

  constructor: (player) ->

  unbind: (player) ->

  broadcastMessage: (player, message) ->
    player.playerManager.game.broadcast MessageCreator.genericMessage message

Personality::isPhysical = (test) ->
  test in Constants.classCategorization.physical

Personality::isMagical = (test) ->
  test in Constants.classCategorization.magical

Personality::isMedic = (test) ->
  test in Constants.classCategorization.medic

Personality::isDPS = (test) ->
  test in Constants.classCategorization.dps

Personality::isTank = (test) ->
  test in Constants.classCategorization.tank

Personality::isSupport = (test) ->
  test in Constants.classCategorization.support

Personality::allPersonalities = -> personalities

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new personalities[personality] forWho

module.exports = exports = Personality