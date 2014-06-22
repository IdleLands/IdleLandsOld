
Datastore = require "nedb"

class PlayerManager

  players: []

  salt: "IdleGame"

  constructor: () ->
    @db = new Datastore { filename: "data/players.nedb", autoload: true }
    @db.ensureIndex { fieldName: 'identifier', unique: true }

  registerPlayer: (options, middleware, callback) ->

    [identifier, name] = [options.identifier, options.name]

    player =
      level: 0
      identifier: identifier
      name: name

    @db.find {identifier: identifier}, (err, docs) =>
      if err
        callback err
        return

      @db.insert player, (iErr, docs) =>
        if iErr
          callback iErr
          return

        callback { success: true, name: name }
        @loginPlayer options

  savePlayer: (player) ->
    @db.update { identifier: player.identifier }, player, (e) ->
      console.error e if e

module.exports = exports = PlayerManager