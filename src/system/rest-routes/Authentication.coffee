hasValidToken = require "./HasValidToken"
API = require "../API"
charCreateTimeout = require("./Brutes").CharCreateTimer

module.exports = (router) ->
  # player routes
  router

  .route "/player"

  # register
  .put charCreateTimeout.prevent, (req, res) ->
    API.player.auth.register req.body
    .then (resp) -> res.json resp

  # logout
  .delete hasValidToken, (req, res) ->
    {identifier} = req.body
    API.player.auth.logout identifier
    .then (resp) -> res.json resp

  # login
  .post (req, res) ->
    {identifier, password} = req.body
    API.player.auth.loginWithPassword identifier, password
    .then (resp) -> res.json resp

  # change pass
  .patch hasValidToken, (req, res) ->
    {identifier, password} = req.body
    API.player.auth.setPassword identifier, password
    .then (resp) -> res.json resp