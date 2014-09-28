
requireDir = require "require-dir"
achievements = requireDir "../character/achievements", recurse: yes
_ = require "underscore"

achievements = _.map achievements, (proto) -> new proto

class AchievementManager
  constructor: (@game) ->

AchievementManager::allAchievements = -> achievements
AchievementManager::getAllAchievedFor = (player) ->
  _.reduce achievements, ((prev, achievement) -> _.union prev, achievement.getAllAchievedFor player), []

module.exports = exports = AchievementManager