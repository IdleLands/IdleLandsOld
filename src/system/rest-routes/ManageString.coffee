hasValidToken = require "./HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# string management
.put "/player/manage/string/add", hasValidToken, (req, res) ->
  {identifier, type, msg} = req.body
  API.player.string.set identifier, type, msg
  .then (resp) -> res.json resp

.post "/player/manage/string/remove", hasValidToken, (req, res) ->
  {identifier, type} = req.body
  API.player.string.remove identifier, type
  .then (resp) -> res.json resp

module.exports = router