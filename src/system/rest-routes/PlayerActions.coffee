hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# title management
.post "/player/action/teleport", hasValidToken, (req, res) ->
  {identifier, newLoc} = req.body
  API.player.action.teleport identifier, newLoc
  .then (resp) -> res.json resp

module.exports = router