hasValidToken = require "./HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# personality management
.route "/player/manage/personality"
.put hasValidToken, (req, res) ->
  {identifier, newPers} = req.body
  API.player.personality.add identifier, newPers
  .then (resp) -> res.json resp

.delete hasValidToken, (req, res) ->
  {identifier, oldPers} = req.body
  API.player.personality.remove identifier, oldPers
  .then (resp) -> res.json resp

module.exports = router