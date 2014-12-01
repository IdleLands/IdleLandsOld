API = require "../API"
mapTimeout = require("./../rest-helpers/Brutes").MapRequestTimer
router = (require "express").Router()

router

# take turn
.route "/game/map"
.post mapTimeout.prevent, (req, res) ->
  {map} = req.body
  res.json {isSuccess: yes, code: 103, message: "Map retrieved successfully.", map: API.game.content.map map}

module.exports = router