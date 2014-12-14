hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# pet management
.put "/pet/buy", hasValidToken, (req, res) ->
  {identifier, type, name, attrs} = req.body
  API.player.pet.buy identifier, type, name, attrs[0], attrs[1]
  .then (resp) -> res.json resp

.post "/pet/upgrade", hasValidToken, (req, res) ->
  {identifier, stat} = req.body
  API.player.pet.upgrade identifier, stat
  .then (resp) -> res.json resp

.put "/pet/feed", hasValidToken, (req, res) ->
  {identifier, gold} = req.body
  API.player.pet.feed identifier, gold
  .then (resp) -> res.json resp

.put "/pet/smart", hasValidToken, (req, res) ->
  {identifier, option, value} = req.body
  API.player.pet.setOption identifier, option, value
  .then (resp) -> res.json resp

.patch "/pet/swap", hasValidToken, (req, res) ->
  {identifier, petId} = req.body
  API.player.pet.swapToPet identifier, petId
  .then (resp) -> res.json resp

.put "/pet/inventory/give", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.giveEquipment identifier, itemSlot
  .then (resp) -> res.json resp

.post "/pet/inventory/take", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.takeEquipment identifier, itemSlot
  .then (resp) -> res.json resp

.patch "/pet/inventory/sell", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.sellEquipment identifier, itemSlot
  .then (resp) -> res.json resp

.put "/pet/inventory/equip", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.equipItem identifier, itemSlot
  .then (resp) -> res.json resp

.post "/pet/inventory/unequip", hasValidToken, (req, res) ->
  {identifier, itemUid} = req.body
  API.player.pet.unequipItem identifier, itemUid
  .then (resp) -> res.json resp


module.exports = router