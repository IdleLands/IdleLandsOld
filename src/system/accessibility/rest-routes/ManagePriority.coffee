hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# personality management
## TAG:APIROUTE: PUT | /player/manage/priority/add | {identifier, stat, points, token} | {player}
.put "/player/manage/priority/add", hasValidToken, (req, res) ->
  {identifier, stat, points} = req.body
  API.player.priority.add identifier, stat, points
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /player/manage/priority/set | {identifier, stats, token} | {player}
.put "/player/manage/priority/set", hasValidToken, (req, res) ->
  {identifier, stats} = req.body
  API.player.priority.set identifier, stats
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /player/manage/priority/remove | {identifier, stat, points, token} | {player}
.post "/player/manage/priority/remove", hasValidToken, (req, res) ->
  {identifier, stat, points} = req.body
  API.player.priority.remove identifier, stat, points
  .then (resp) -> res.json resp

module.exports = router