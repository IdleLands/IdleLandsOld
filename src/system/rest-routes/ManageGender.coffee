hasValidToken = require "./HasValidToken"
API = require "../API"
router = (require "express").Router()

router
# gender management
.route "/player/manage/gender"
.put hasValidToken, (req, res) ->
  {identifier, gender} = req.body
  API.player.gender identifier, gender
  .then (resp) -> res.json resp

module.exports = router