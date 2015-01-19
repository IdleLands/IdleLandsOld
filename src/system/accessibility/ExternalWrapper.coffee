

module.exports = exports = () ->

  @load = () =>

    @api = require "./API"
    @api.gameInstance = new (require "./../Game")

  @