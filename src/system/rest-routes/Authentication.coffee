hasValidToken = require "./HasValidToken"
API = require "../API"
charCreateTimeout = require("./Brutes").CharCreateTimer
loginRequestTimeout = require("./Brutes").LoginRequestTimer

router = (require "express").Router()

# player routes
router

# register
.put "/player/auth/register", charCreateTimeout.prevent, (req, res) ->
  API.player.auth.register req.body
  .then (resp) ->
    req.brute.reset() if not resp.isSuccess
    res.json resp

# logout
.post "/player/auth/logout", hasValidToken, (req, res) ->
  {identifier} = req.body
  API.player.auth.logout identifier
  .then (resp) -> res.json resp

# login
.post "/player/auth/login", loginRequestTimeout.prevent, (req, res) ->
  {identifier, password} = req.body
  API.player.auth.loginWithPassword identifier, password
  .then (resp) -> res.json resp

# change pass
.patch "/player/auth/password", hasValidToken, (req, res) ->
  {identifier, password} = req.body
  API.player.auth.setPassword identifier, password
  .then (resp) -> res.json resp

module.exports = router