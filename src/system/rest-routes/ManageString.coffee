hasValidToken = require "./HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# string management
.route "/player/manage/string"
.put hasValidToken, (req, res) ->
  {identifier, type, msg} = req.body
  API.player.string.set identifier, type, msg
  .then (resp) -> res.json resp

.delete hasValidToken, (req, res) ->
  {identifier, type} = req.body
  API.player.string.remove identifier, type
  .then (resp) -> res.json resp

module.exports = router