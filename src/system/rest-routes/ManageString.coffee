hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# string management
.put "/player/manage/string/set", hasValidToken, (req, res) ->
  {identifier, type, msg} = req.body
  API.player.string.set identifier, type, msg
  .then (resp) -> res.json resp

.post "/player/manage/string/remove", hasValidToken, (req, res) ->
  {identifier, type} = req.body
  API.player.string.remove identifier, type
  .then (resp) -> res.json resp

module.exports = router
