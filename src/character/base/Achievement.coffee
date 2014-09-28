
class Achievement

  @getAchieved = -> []

Achievement::log = (base, number) -> (Math.log number) / Math.log base

module.exports = exports = Achievement