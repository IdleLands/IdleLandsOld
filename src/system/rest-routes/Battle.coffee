API = require "../API"
router = (require "express").Router()

router

# take turn
.route "/game/battle"
.post (req, res) ->
  {battleId} = req.body
  API.game.content.battle battleId
  .then (resp) ->
    res.json resp

module.exports = router