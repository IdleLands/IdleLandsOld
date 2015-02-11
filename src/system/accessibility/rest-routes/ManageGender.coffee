hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"
router = (require "express").Router()

router
  
# gender management
## TAG:APIROUTE: PUT | /player/manage/gender/set | {identifier, gender, token} | {}
.put "/player/manage/gender/set", hasValidToken, (req, res) ->
  {identifier, gender} = req.body
  API.player.gender.set identifier, gender
  .then (resp) -> res.json resp

module.exports = router