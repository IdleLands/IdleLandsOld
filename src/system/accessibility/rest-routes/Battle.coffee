API = require "../API"
router = (require "express").Router()

router

##TAG:APIROUTE_PARAM: battleId | string | The id representing the battle | 16 character Mongo ID

##TAG:APIROUTE_RETVAL: battle | object | The battle object

# take turn
## TAG:APIROUTE: POST | /game/battle | {battleId} | {battle}
.route "/game/battle"
.post (req, res) ->
  {battleId} = req.body
  len = battleId.length
  if not (11 < len < 25)
    res.json {isSuccess: no, code: 122, message: "Battle IDs must be 12-24 characters."}
  else
    API.game.content.battle battleId
    .then (resp) ->
      res.json resp

module.exports = router