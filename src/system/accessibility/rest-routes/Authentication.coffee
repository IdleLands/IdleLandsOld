hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
charCreateTimeout = require("./../rest-helpers/Brutes").CharCreateTimer
loginRequestTimeout = require("./../rest-helpers/Brutes").LoginRequestTimer

router = (require "express").Router()

# player routes
router

# register
## TAG:APIROUTE: PUT | /player/auth/register | {identifier, name, password} | {player, token}
.put "/player/auth/register", charCreateTimeout.prevent, (req, res) ->
  API.player.auth.register req.body
  .then (resp) ->
    req.brute.reset() if not resp.isSuccess
    res.json resp

# logout
## TAG:APIROUTE: POST | /player/auth/logout | {identifier, token} | {}
.post "/player/auth/logout", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.auth.logout identifier
  .then (resp) -> res.json resp

# login
## TAG:APIROUTE: POST | /player/auth/login | {identifier, password} | {player, token}
.post "/player/auth/login", loginRequestTimeout.prevent, (req, res) ->
  {identifier, password} = req.body
  API.player.auth.loginWithPassword identifier, password
  .then (resp) -> res.json resp

# change pass
## TAG:APIROUTE: POST | /player/auth/password | {identifier, password, token} | {}
.patch "/player/auth/password", hasValidToken, (req, res) ->
  {identifier, password} = req.body
  API.player.auth.setPassword identifier, password
  .then (resp) -> res.json resp

module.exports = router