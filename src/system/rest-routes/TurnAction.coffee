hasValidToken = require "./HasValidToken"
API = require "../API"
turnTimeout = require("./Brutes").TurnTimeoutTimer

module.exports = (router) ->
  router

  # take turn
  .route "/player/action/turn"
  .post turnTimeout.prevent, hasValidToken, (req, res) ->
    {identifier} = req.body
    API.player.nextAction identifier
    .then (resp) -> res.json resp