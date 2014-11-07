API = require "../API"
router = (require "express").Router()

router

# take turn
.route "/game/battle"
.post (req, res) ->
  {battleId} = req.body
  res.json API.game.content.battle battleId

module.exports = router