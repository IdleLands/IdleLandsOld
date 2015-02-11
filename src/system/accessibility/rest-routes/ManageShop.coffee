hasValidToken = require "./../rest-helpers/HasValidToken"
API = require "../API"

router = (require "express").Router()

router

# shop management
## TAG:APIROUTE: PUT | /player/manage/shop/buy | {identifier, shopSlot, token} | {player}
.put "/player/manage/shop/buy", hasValidToken, (req, res) ->
  {identifier, shopSlot} = req.body
  API.player.shop.buy identifier, shopSlot
  .then (resp) -> res.json resp

module.exports = router