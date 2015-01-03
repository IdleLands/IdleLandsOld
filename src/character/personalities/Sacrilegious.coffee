
Personality = require "../base/Personality"

`/**
  * This personality makes you never have events happen. In general.
  *
  * @name Sacrilegious
  * @prerequisite Find a forsaken item
  * @effect bad events happen often
  * @effect all events happen more
  * @category Personalities
  * @package Player
*/`
class Sacrilegious extends Personality
  constructor: ->

  eventModifier: (player, event) -> if event.type in ['forsakeItem', 'forsakeXp', 'forsakeGold', 'flipStat'] then 700 else 350

  @canUse = (player) ->
    player.permanentAchievements?.hasFoundForsaken

  @desc = "Find a forsaken item"

module.exports = exports = Sacrilegious