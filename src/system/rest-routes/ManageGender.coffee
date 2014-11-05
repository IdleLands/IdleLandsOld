hasValidToken = require "./HasValidToken"
API = require "../API"
router = (require "express").Router()

router
  
# gender management
.put "/player/manage/gender/set", hasValidToken, (req, res) ->
  {identifier, gender} = req.body
  API.player.gender.set identifier, gender
  .then (resp) -> res.json resp

.post "/player/manage/gender/remove", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.gender.remove identifier
  .then (resp) -> res.json resp

module.exports = router