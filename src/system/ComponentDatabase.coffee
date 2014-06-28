
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID

class ComponentDatabase

  constructor: (@game) ->
    @eventsDb = new Datastore "events", {random: '2dsphere'}

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

module.exports = exports = ComponentDatabase