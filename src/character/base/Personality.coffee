
requireDir = require "require-dir"
personalities = requireDir "../personalities"

class Personality

  constructor: ->

  calculateYesPercentBonus: -> 0

  calculateItemScoreBonus: (item) -> 0

  partyFormationProbabilityBonus: (potentialGroup) -> 0

  itemReplacementRangeBonus: (item) -> Math.floor item.score()*0.25

  calculateAdditionalGoldGainedFromItem: (item) -> 0

  calculateBonusStepsToTakeThisTurn: -> 0

  calculateDamageTakenFromAttack: (attack) -> 0

  ###
  https://docs.google.com/document/d/1t6PaUgnWODi9SujRd_sewnVVWvVm6zLAssIYIivui4s/edit

  each class should bestow a personality trait on the user while in that class
  mage - passive +mp, etc
  ###

Personality::doesPersonalityExist = (personality) ->
  personality of personalities

Personality::createPersonality = (personality) ->
  new personalities[personality]

module.exports = exports = Personality