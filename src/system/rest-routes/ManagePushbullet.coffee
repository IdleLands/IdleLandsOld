hasValidToken = require "./HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# pushbullet management
.route "/player/manage/pushbullet"
.put hasValidToken, (req, res) ->
  {identifier, apiKey} = req.body
  API.player.pushbullet.set identifier, apiKey
  .then (resp) -> res.json resp

.delete hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.pushbullet.remove identifier
  .then (resp) -> res.json resp

module.exports = router