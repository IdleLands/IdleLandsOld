hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()
customContentTimer = require("./../rest-helpers/Brutes").CustomContentTimer

router
  
## TAG:APIROUTE: PUT | /custom/player/submit | {identifier, data: {type, content}} | {}
.put "/custom/player/submit", hasValidToken, customContentTimer.prevent, (req, res) ->
  {identifier, data} = req.body
  API.player.custom.submit identifier, data
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /custom/redeem | {identifier, crierId, giftId} | {}
.post "/custom/redeem", hasValidToken, (req, res) ->
  {identifier, crierId, giftId} = req.body
  API.player.custom.redeemGift identifier, crierId, giftId
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /custom/mod/list | {identifier} | {customs}
.post "/custom/mod/list", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.gm.custom.list identifier
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /custom/mod/approve | {identifier} | {}
.patch "/custom/mod/approve", hasValidToken, (req, res) ->
  {identifier, ids} = req.body
  API.gm.custom.approve identifier, ids
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /custom/mod/reject | {identifier} | {}
.patch "/custom/mod/reject", hasValidToken, (req, res) ->
  {identifier, ids} = req.body
  API.gm.custom.reject identifier, ids
  .then (resp) -> res.json resp

module.exports = router