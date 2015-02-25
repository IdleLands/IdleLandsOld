
config = require "../../../config.json"
useDebug = config.debug.enabled

webrepl = require "webrepl"

module.exports = (game) ->

  return unless useDebug

  {port, user, pass} = config.debug

  api = require "./API"

  webrepl.start(port, {username: user, password: pass, hostname: '0.0.0.0'}).context.idle =
    inst: game

    playerm: game.playerManager
    petm: game.petManager
    guildm: game.guildManager

    player: api.player
    gm: api.gm

    pname: (name) -> game.playerManager.getPlayerByName name
    gname: (name) -> game.guildManager.getGuildByName name

    pid: (id) -> game.playerManager.getPlayerById id

    event: (player, event) -> api.gm.event.single player, event
    gevent: (event) -> api.gm.event.global event

  console.log "Debug started on port #{port}."