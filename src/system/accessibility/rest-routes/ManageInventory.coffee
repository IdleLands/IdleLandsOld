hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# inventory management
## TAG:APIROUTE: PUT | /player/manage/inventory/add | {identifier, itemSlot, token} | {player}
.put "/player/manage/inventory/add", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.overflow.add identifier, itemSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /player/manage/inventory/sell | {identifier, invSlot, token} | {player}
.post "/player/manage/inventory/sell", hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.sell identifier, invSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /player/manage/inventory/swap | {identifier, invSlot, token} | {player}
.patch "/player/manage/inventory/swap", hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.swap identifier, invSlot
  .then (resp) -> res.json resp

module.exports = router