
Personality = require "../base/Personality"

`/**
  * This personality makes you never join parties.
  *
  * @name Solo
  * @prerequisite Join 500 parties
  * @prerequisite Have 5 allies flee while in your party
  * @effect You never seek out parties, nor are you placed in them
  * @category Personalities
  * @package Player
*/`
class Solo extends Personality
  constructor: ->

  @canUse = (player) ->
    player.statistics["player party join"] >= 500 and player.statistics["combat ally flee"] >= 5

  @desc = "Join 500 parties and witness 5 allies flee"

module.exports = exports = Solo