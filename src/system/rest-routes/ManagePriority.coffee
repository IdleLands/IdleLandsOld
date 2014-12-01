hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# personality management
.put "/player/manage/priority/add", hasValidToken, (req, res) ->
  {identifier, stat, points} = req.body
  API.player.priority.add identifier, stat, points
  .then (resp) -> res.json resp

.post "/player/manage/priority/remove", hasValidToken, (req, res) ->
  {identifier, stat, points} = req.body
  API.player.priority.remove identifier, stat, points
  .then (resp) -> res.json resp

module.exports = router