API = require "../API"
mapTimeout = require("./Brutes").MapRequestTimer
router = (require "express").Router()

router

# take turn
.route "/game/map"
.post mapTimeout.prevent, (req, res) ->
  {map} = req.body
  res.json API.game.content.map map

module.exports = router