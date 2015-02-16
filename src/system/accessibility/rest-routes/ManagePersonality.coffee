hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# personality management
## TAG:APIROUTE: PUT | /player/manage/personality/add | {identifier, newPers, token} | {}
.put "/player/manage/personality/add", hasValidToken, (req, res) ->
  {identifier, newPers} = req.body
  API.player.personality.add identifier, newPers
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /player/manage/personality/remove | {identifier, oldPers, token} | {}
.post "/player/manage/personality/remove", hasValidToken, (req, res) ->
  {identifier, oldPers} = req.body
  API.player.personality.remove identifier, oldPers
  .then (resp) -> res.json resp

module.exports = router