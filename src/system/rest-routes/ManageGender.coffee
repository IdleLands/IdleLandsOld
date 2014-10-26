hasValidToken = require "./HasValidToken"
API = require "../API"

module.exports = (router) ->
  router

  # gender management
  .route "/player/manage/gender"
  .put hasValidToken, (req, res) ->
    {identifier, gender} = req.body
    API.player.gender identifier, gender
    .then (resp) -> res.json resp

  .delete hasValidToken, (req, res) ->
    {identifier} = req.body
    API.player.gender identifier, ''
    .then (resp) -> res.json resp