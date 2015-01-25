hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# guild leave/join

.put "/guild/create", hasValidToken, (req, res) ->
  {identifier, guildName} = req.body
  API.player.guild.create identifier, guildName
  .then (resp) -> res.json resp

.post "/guild/leave", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.guild.leave identifier
  .then (resp) -> res.json resp

.put "/guild/disband", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.guild.disband identifier
  .then (resp) -> res.json resp

#Invites

.put "/guild/invite/player", hasValidToken, (req, res) ->
  {identifier, invName} = req.body
  API.player.guild.invite identifier, invName
  .then (resp) -> res.json resp

.post "/guild/invite/manage", hasValidToken, (req, res) ->
  {identifier, accepted, guildName} = req.body
  API.player.guild.manageInvite identifier, accepted, guildName
  .then (resp) -> res.json resp

#Manage

.post "/guild/manage/promote", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.promote identifier, memberName
  .then (resp) -> res.json resp

.post "/guild/manage/demote", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.demote identifier, memberName
  .then (resp) -> res.json resp

.post "/guild/manage/kick", hasValidToken, (req, res) ->
  {identifier, memberName} = req.body
  API.player.guild.kick identifier, memberName
  .then (resp) -> res.json resp

.post "/guild/manage/donate", hasValidToken, (req, res) ->
  {identifier, gold} = req.body
  API.player.guild.donate identifier, gold
  .then (resp) -> res.json resp

.post "/guild/manage/buff", hasValidToken, (req, res) ->
  {identifier, type, tier} = req.body
  API.player.guild.buff identifier, type, tier
  .then (resp) -> res.json resp

.post "/guild/manage/tax", hasValidToken, (req, res) ->
  {identifier, taxPercent} = req.body
  API.player.guild.tax.whole identifier, taxPercent
  .then (resp) -> res.json resp

.post "/player/manage/tax", hasValidToken, (req, res) ->
  {identifier, taxPercent} = req.body
  API.player.guild.tax.self identifier, taxPercent
  .then (resp) -> res.json resp

module.exports = router