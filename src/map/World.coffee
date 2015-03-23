Map = require "./Map"
_ = require "lodash"
fs = require "fs"

class World

  maps: {}
  uniqueRegions: []

  constructor: (@game) ->
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
      map = new Map mapObj.path, @game
      @maps[mapObj.map] = map

      @uniqueRegions.push (_.uniq _.compact map.regionMap)...

module.exports = exports = World