
class API

  @gameInstance: null

  @registerPlayer: (options, middlware, callback) ->
    @gameInstance.playerManager.registerPlayer options, middlware, callback

  @nextAction: (identifier) ->
    @gameInstance.nextAction identifier

module.exports = exports = API