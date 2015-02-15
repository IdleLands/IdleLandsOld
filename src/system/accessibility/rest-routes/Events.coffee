API = require "../API"
router = (require "express").Router()

router

##TAG:APIROUTE_PARAM: filterPlayers | (optional) array | A list of players to filter events down to, if any | Array of player names
##TAG:APIROUTE_PARAM: newerThan | (optional) date | A timestamp which signifies the last event in your catalog | none

##TAG:APIROUTE_RETVAL: events | array | A list of events, if any were selected by given filters

## TAG:APIROUTE: POST | /game/events/small | {filterPlayers, newerThan} | {events}
.post "/game/events/small", (req, res) ->
  {filterPlayers, newerThan} = req.body
  API.game.events.small filterPlayers, newerThan
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /game/events/medium | {filterPlayers, newerThan} | {events}
.post "/game/events/medium", (req, res) ->
  {filterPlayers, newerThan} = req.body
  API.game.events.medium filterPlayers, newerThan
  .then (resp) -> res.json resp

## TAG:APIROUTE: POST | /game/events/large | {filterPlayers, newerThan} | {events}
.post "/game/events/large", (req, res) ->
  {filterPlayers, newerThan} = req.body
  API.game.events.large filterPlayers, newerThan
  .then (resp) -> res.json resp

module.exports = router