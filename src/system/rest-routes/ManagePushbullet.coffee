hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# pushbullet management
.put "/player/manage/pushbullet/set", hasValidToken, (req, res) ->
  {identifier, apiKey} = req.body
  API.player.pushbullet.set identifier, apiKey
  .then (resp) -> res.json resp

.post "/player/manage/pushbullet/remove", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.pushbullet.remove identifier
  .then (resp) -> res.json resp

module.exports = router