
_ = require "lodash"

GlobalEvent = require "../GlobalEvent"

`/**
 * This event causes larger or smaller-scale events to happen all over the world, generally causing chaos of some sort.
 *
 * @name Cataclysm
 * @category Global
 * @package Events
 * @happensEvery 80 minutes
 */`
requireDir = require "require-dir"
cataclysms = requireDir "../cataclysms"

class CataclysmEvent extends GlobalEvent
  go: ->
    cata = new cataclysms[_.sample _.keys cataclysms] @game
    do cata.go

module.exports = exports = CataclysmEvent