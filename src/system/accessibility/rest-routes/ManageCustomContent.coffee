hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()
customContentTimer = require("./../rest-helpers/Brutes").CustomContentTimer

router
  
# gender management
.put "/custom/player/submit", hasValidToken, customContentTimer.prevent, (req, res) ->
  {identifier, data} = req.body
  API.player.custom.submit identifier, data
  .then (resp) -> res.json resp

.post "/custom/redeem", hasValidToken, (req, res) ->
  {identifier, crierId, giftId} = req.body
  API.player.custom.redeemGift identifier, crierId, giftId
  .then (resp) -> res.json resp

.post "/custom/mod/list", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.gm.custom.list identifier
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