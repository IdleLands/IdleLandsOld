API = require "../API"
mapTimeout = require("./../rest-helpers/Brutes").MapRequestTimer
router = (require "express").Router()

router

# take turn
## TAG:APIROUTE: POST | /game/map | {map} | {map}
.route "/game/map"
.post (req, res) ->
  {map} = req.body
  res.json {isSuccess: yes, code: 103, message: "Map retrieved successfully.", map: API.game.content.map map}

module.exports = router