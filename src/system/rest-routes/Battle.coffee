API = require "../API"
mapTimeout = require("./Brutes").MapRequestTimer
router = (require "express").Router()

router

# take turn
.route "/game/battle"
.post mapTimeout.prevent, (req, res) ->
  {battleId} = req.body
  res.json API.game.content.battle battleId

module.exports = router