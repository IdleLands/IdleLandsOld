hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# guild leave/join

## TAG:APIROUTE: PUT | /guild/create | {identifier, guildName, token} | {guild}
.put "/guild/create", hasValidToken, (req, res) ->
  {identifier, guildName} = req.body
  API.player.guild.create identifier, guildName
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/leave | {identifier, token} | {guild}
.post "/guild/leave", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.guild.leave identifier
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /guild/leave | {identifier, token} | {guild}
.put "/guild/disband", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.guild.disband identifier
  .then (resp) -> res.json resp

#Invites

## TAG:APIROUTE: PUT | /guild/invite/player | {identifier, invName, token} | {guild}
.put "/guild/invite/player", hasValidToken, (req, res) ->
  {identifier, invName} = req.body
  API.player.guild.invite identifier, invName
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/invite/manage | {identifier, accepted, token} | {guild}
.post "/guild/invite/manage", hasValidToken, (req, res) ->
  {identifier, accepted, guildName} = req.body
  API.player.guild.manageInvite identifier, accepted, guildName
  .then (resp) -> res.json resp

#Manage

## TAG:APIROUTE: POST | /guild/manage/promote | {identifier, memberName, token} | {guild}
.post "/guild/manage/promote", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.promote identifier, memberName
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/manage/demote | {identifier, memberName, token} | {guild}
.post "/guild/manage/demote", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.demote identifier, memberName
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/manage/kick | {identifier, memberName, token} | {guild}
.post "/guild/manage/kick", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.kick identifier, memberName
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/manage/donate | {identifier, gold, token} | {}
.post "/guild/manage/donate", hasValidToken, (req, res) ->
  {identifier, gold} = req.body
  API.player.guild.donate identifier, gold
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/manage/buff | {identifier, type, tier, token} | {guild}
.post "/guild/manage/buff", hasValidToken, (req, res) ->
  {identifier, type, tier} = req.body
  API.player.guild.buff identifier, type, tier
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/manage/tax | {identifier, taxPercent, token} | {guild}
.post "/guild/manage/tax", hasValidToken, (req, res) ->
  {identifier, taxPercent} = req.body
  API.player.guild.tax.whole identifier, taxPercent
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /player/manage/tax | {identifier, taxPercent, token} | {player}
.post "/player/manage/tax", hasValidToken, (req, res) ->
  {identifier, taxPercent} = req.body
  API.player.guild.tax.self identifier, taxPercent
  .then (resp) -> res.json resp

# Base / Buildings

## TAG:APIROUTE: PUT | /guild/building/construct | {identifier, building, slot, token} | {player}
.put "/guild/building/construct", hasValidToken, (req, res) ->
  {identifier, building, slot} = req.body
  API.player.guild.construct identifier, building, slot
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /guild/building/upgrade | {identifier, building, token} | {player}
.post "/guild/building/upgrade", hasValidToken, (req, res) ->
  {identifier, building} = req.body
  API.player.guild.upgrade identifier, building
  .then (resp) -> res.json resp

## TAG:APIROUTE: PATCH | /guild/building/setProperty | {identifier, building, property, value} | {guild}
.put "/guild/building/setProperty", hasValidToken, (req, res) ->
  {identifier, building, property, value} = req.body
  API.player.guild.setProperty identifier, building, property, value
  .then (resp) -> res.json resp

## TAG:APIROUTE: PUT | /guild/move | {identifier, newLoc, token} | {player}
.put "/guild/move", hasValidToken, (req, res) ->
  {identifier, newLoc} = req.body
  API.player.guild.move identifier, newLoc
  .then (resp) -> res.json resp

module.exports = router