hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router
  
# gender management
.put "/custom/player/submit", hasValidToken, (req, res) ->
  {identifier, data} = req.body
  API.player.custom.submit identifier, data
  .then (resp) -> res.json resp

.patch "/custom/mod/approve", hasValidToken, (req, res) ->
  {identifier, ids} = req.body
  API.gm.custom.approve identifier, ids
  .then (resp) -> res.json resp

.patch "/custom/mod/reject", hasValidToken, (req, res) ->
  {identifier, ids} = req.body
  API.gm.custom.reject identifier, ids
  .then (resp) -> res.json resp

module.exports = router