
requireDir = require "require-dir"
personalities = requireDir "../personalities"

class Personality

  personalities: personalities

  calculateYesPercentBonus: -> 0

  calculateItemScoreBonus: (item) -> 0

  partyFormationProbabilityBonus: (potentialGroup) -> 0

  shouldReplaceItem: (item) -> null

  calculateAdditionalGoldGainedFromItem: (item) -> 0

  calculateBonusStepsToTakeThisTurn: -> 0

  calculateDamageTakenFromAttack: (attack) ->

  ###
  https://docs.google.com/document/d/1t6PaUgnWODi9SujRd_sewnVVWvVm6zLAssIYIivui4s/edit

  each class should bestow a personality trait on the user while in that class
  mage - passive +mp, etc
  ###

Personality::doesPersonalityExist = (personality) ->
  personality+"Personality" of @personalities

module.exports = exports = Personality