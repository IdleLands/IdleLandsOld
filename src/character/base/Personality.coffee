
requireDir = require "require-dir"
personalities = requireDir "../personalities"
MessageCreator = require "../../system/MessageCreator"
Constants = require "../../system/Constants"

class Personality

  @isPhysical = (test) ->
    test in Constants.classCategorization.physical

  @isMagical = (test) ->
    test in Constants.classCategorization.magical

  @isMedic = (test) ->
    test in Constants.classCategorization.medic

  @isDPS = (test) ->
    test in Constants.classCategorization.dps

  @isTank = (test) ->
    test in Constants.classCategorization.tank

  @isSupport = (test) ->
    test in Constants.classCategorization.support

  constructor: (player) ->

  unbind: (player) ->

  broadcastMessage: (player, message) ->
    player.playerManager.game.broadcast MessageCreator.genericMessage message

Personality::allPersonalities = -> personalities

Personality::getPersonality = (personality) ->
  personalities[personality]

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality, forWho) ->
  new personalities[personality] forWho

module.exports = exports = Personality