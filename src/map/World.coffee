Map = require "./Map"
_ = require "underscore"
fs = require "fs"

class World

  maps: {}

  constructor: ->
    walk = (dir) ->
      results = []
      list = fs.readdirSync dir

      list.forEach (baseFileName) ->
        file = dir + '/' + baseFileName
        stat = fs.statSync file
        if stat and stat.isDirectory() then results = results.concat walk file
        else results.push map: (baseFileName.split(".")[0]), path: file

      results

    _.each (walk "#{__dirname}/../../assets/map"), (mapObj) =>
      @maps[mapObj.map] = new Map mapObj.path

module.exports = exports = World