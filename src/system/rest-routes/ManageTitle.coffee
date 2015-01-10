hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router

# title management
.put "/player/manage/title/set", hasValidToken, (req, res) ->
  {identifier, newTitle} = req.body
  API.player.title.set identifier, newTitle
  .then (resp) -> res.json resp

.post "/player/manage/title/remove", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.title.set identifier, ''
  .then (resp) -> res.json resp

module.exports = router