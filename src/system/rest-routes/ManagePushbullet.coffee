hasValidToken = require "./HasValidToken"
API = require "../API"

module.exports = (router) ->
  router

  # pushbullet management
  .route "/player/manage/pushbullet"
  .put hasValidToken, (req, res) ->
    {identifier, apiKey} = req.body
    API.player.pushbullet.set identifier, apiKey
    .then (resp) -> res.json resp

  .delete hasValidToken, (req, res) ->
    {identifier} = req.body
    API.player.pushbullet.remove identifier
    .then (resp) -> res.json resp