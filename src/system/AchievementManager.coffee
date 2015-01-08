
requireDir = require "require-dir"
achievements = requireDir "../character/achievements", recurse: yes
_ = require "lodash"

achievements = _.map achievements, (proto) -> new proto

class AchievementManager
  constructor: (@game) ->

AchievementManager::allAchievements = -> achievements
AchievementManager::getAllAchievedFor = (player) ->
  _.reduce achievements, ((prev, achievement) ->
    arr = prev
    arr.push (achievement.getAllAchievedFor player)...
    arr
  ), []

module.exports = exports = AchievementManager