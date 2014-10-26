hasValidToken = require "./HasValidToken"
API = require "../API"

module.exports = (router) ->
  router

  # take turn
  .route "/player/action/turn"
  .post turnTimeout.prevent, hasValidToken, (req, res) ->
    {identifier} = req.body
    API.player.nextAction identifier
    .then (resp) -> res.json resp