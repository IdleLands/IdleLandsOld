
Achievement = require "../base/Achievement"
Personality = require "../base/Personality"
_ = require "underscore"

`/**
  * This achievement was earned by participating in IdleLands Alpha.
  *
  * @name α Test Subject
  * @prerequisite Be an alpha tester.
  * @reward +5 XP
  * @reward +500 HP
  * @reward +[playerLevel/10] LUCK
  * @reward +[playerLevel*2] STR
  * @reward +[playerLevel*2] DEX
  * @reward +[playerLevel*2] CON
  * @reward +[playerLevel*2] INT
  * @reward +[playerLevel*2] AGI
  * @reward +[playerLevel*2] WIS
  * @category Achievements
  * @package Player
*/`
class Tester extends Achievement

  getAllAchievedFor: (player) ->

    achieved = []

    if player.permanentAchievements?.isAlphaTester
      achieved.push
        name: "α Test Subject"
        desc: "Survived alpha testing"
        reward: "+5xp, +500hp, +0.1 Luck per level, +2 STR/INT/WIS/CON/DEX/AGI per level"
        xp: -> 5
        hp: -> 500
        luck: (player) -> player.level.getValue() * 0.1
        str: (player) -> player.level.getValue() * 2
        int: (player) -> player.level.getValue() * 2
        con: (player) -> player.level.getValue() * 2
        dex: (player) -> player.level.getValue() * 2
        agi: (player) -> player.level.getValue() * 2
        wis: (player) -> player.level.getValue() * 2
        type: "special"

    achieved


module.exports = exports = Tester