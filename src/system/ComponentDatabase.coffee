
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "underscore"

class ComponentDatabase

  itemStats: {}

  constructor: (@game) ->
    @eventsDb = new Datastore "events", {random: '2dsphere'}
    @itemsDb = new Datastore "items", {random: '2dsphere'}

    @loadItems()

  insertYesNo: (question, y, n) ->
    @eventsDb.insert
      type: 'yesno'
      question: question
      y: y
      n: n
      random: [Math.random(), 0]
    , ->

  insertStatic: (type, remark) ->
    @eventsDb.insert
      type: type
      remark: remark
      random: [Math.random(), 0]
    , ->

  insertItem: (object, duplicateCallback) ->
    console.log 'attempting to insert',object
    copy = _.extend {}, object
    delete copy.name
    query = [ copy, {name: object.name} ]
    @itemsDb.findOne { $or: query }, (e, doc) =>

      if doc?.name is object.name
        duplicateCallback {name: doc.name}
        return
      else if doc
        duplicateCallback {stats: true}
        return

      @addItem object

  addItem: (object) ->

    @addItemToHash object

    object.random = [Math.random(), 0]
    @itemsDb.insert object, ->

  addItemToHash: (object) ->
    copy = _.extend {}, object

    if not (copy.type of @itemStats)
      @itemStats[copy.type] = []

    @itemStats[copy.type].push copy


  getRandomEvent: (type, callback) ->
    @eventsDb.findOne
      type: type
      random:
        $near:
          $geometry:
            type: "Point"
            coordinates: [Math.random(), 0]
    , callback

  findEvent: (query, callback) ->
    @eventsDb.findOne query, callback

  removeEvent: (id, callback) ->
    @eventsDb.remove
      _id: ObjectID id
    , callback

  loadItems: ->
    @itemsDb.find {}, (e, docs) =>
      _.forEach docs, (item) =>
        @addItemToHash item

module.exports = exports = ComponentDatabase