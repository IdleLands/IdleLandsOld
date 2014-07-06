
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "underscore"
readdirp = require "readdirp"
fs = require "fs"

class ComponentDatabase

  itemStats: {}

  constructor: (@game) ->
    @eventsDb = new Datastore "events", {random: '2dsphere'}
    @itemsDb = new Datastore "items", {random: '2dsphere'}

    @loadItems()

  parseItemString: (str, type) ->
    return if not str.trim()
    if str.indexOf("%") isnt -1
      console.log "error: string still using % format: #{str}"
      return
    [name, parameters] = [str.split("\"")[1], str.split("\"")[2].trim()]

    parameters = _.map (parameters.split ' '), (item) ->
      arr = item.split '='
      retval = {}
      retval[arr[0]] = (parseInt arr[1]) ? null
      retval
    .reduce (cur, prev) ->
      _.extend prev, cur
    , { name: name, type: type }

    @insertItem parameters, ->

  importAllData: ->
    @eventsDb.remove {}, {}, ->
    @itemsDb.remove {}, {}, ->

    itemstream = readdirp {root: "#{__dirname}/../../assets/data/items", fileFilter: "*.txt"}
    itemstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @parseItemString line, type

    eventstream = readdirp {root: "#{__dirname}/../../assets/data/events", fileFilter: "*.txt"}
    eventstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @insertStatic line, type

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