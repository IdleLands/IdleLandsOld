hasValidToken = require "./HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# inventory management
.put "/player/manage/inventory/add", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.overflow.add identifier, itemSlot
  .then (resp) -> res.json resp

.post "/player/manage/inventory/sell", hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.sell identifier, invSlot
  .then (resp) -> res.json resp

.patch "/player/manage/inventory/swap", hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.swap identifier, invSlot
  .then (resp) -> res.json resp

module.exports = router