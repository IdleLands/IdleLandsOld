hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
turnTimeout = require("./../rest-helpers/Brutes").TurnTimeoutTimer
router = (require "express").Router()

router

# take turn
## TAG:APIROUTE: POST | /player/action/turn | {identifier, token} | {player, pet}
.route "/player/action/turn"
.post turnTimeout.prevent, hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.takeTurn identifier
  .then (resp) -> res.json resp

module.exports = router