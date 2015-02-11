hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# pet management

## TAG:APIROUTE: PUT | /pet/buy | {identifier, type, name, attrs, token} | {}
.put "/pet/buy", hasValidToken, (req, res) ->
  {identifier, type, name, attrs} = req.body
  API.player.pet.buy identifier, type, name, attrs[0], attrs[1]
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /pet/upgrade | {identifier, stat, token} | {}
.post "/pet/upgrade", hasValidToken, (req, res) ->
  {identifier, stat} = req.body
  API.player.pet.upgrade identifier, stat
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /pet/feed | {identifier, token} | {}
.put "/pet/feed", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.pet.feed identifier
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /pet/takeGold | {identifier, token} | {}
.post "/pet/takeGold", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.pet.takeGold identifier
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /pet/smart | {identifier, option, value, token} | {}
.put "/pet/smart", hasValidToken, (req, res) ->
  {identifier, option, value} = req.body
  API.player.pet.setOption identifier, option, value
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /pet/swap | {identifier, petId, token} | {}
.patch "/pet/swap", hasValidToken, (req, res) ->
  {identifier, petId} = req.body
  API.player.pet.swapToPet identifier, petId
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /pet/class | {identifier, petClass, token} | {}
.patch "/pet/class", hasValidToken, (req, res) ->
  {identifier, petClass} = req.body
  API.player.pet.changeClass identifier, petClass
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /pet/inventory/give | {identifier, itemSlot, token} | {}
.put "/pet/inventory/give", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.giveEquipment identifier, itemSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /pet/inventory/take | {identifier, itemSlot, token} | {}
.post "/pet/inventory/take", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.takeEquipment identifier, itemSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /pet/inventory/sell | {identifier, itemSlot, token} | {}
.patch "/pet/inventory/sell", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.sellEquipment identifier, itemSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /pet/inventory/equip | {identifier, itemSlot, token} | {}
.put "/pet/inventory/equip", hasValidToken, (req, res) ->
  {identifier, itemSlot} = req.body
  API.player.pet.equipItem identifier, itemSlot
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /pet/inventory/unequip | {identifier, itemUid, token} | {}
.post "/pet/inventory/unequip", hasValidToken, (req, res) ->
  {identifier, itemUid} = req.body
  API.player.pet.unequipItem identifier, itemUid
  .then (resp) -> res.json resp


module.exports = router