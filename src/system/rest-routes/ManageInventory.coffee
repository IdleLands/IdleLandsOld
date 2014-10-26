hasValidToken = require "./HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# inventory management
.route "/player/manage/inventory"
.put hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.overflow.add identifier, itemSlot
  .then (resp) -> res.json resp

.delete hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.sell identifier, invSlot
  .then (resp) -> res.json resp

.patch hasValidToken, (req, res) ->
  {identifier, invSlot} = req.body
  API.player.overflow.swap identifier, invSlot
  .then (resp) -> res.json resp

module.exports = router