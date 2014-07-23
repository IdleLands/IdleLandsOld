
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "underscore"
readdirp = require "readdirp"
fs = require "fs"
Party = require "../event/Party"

class ComponentDatabase

  itemStats: {}

  constructor: (@game) ->
    @eventsDb = new Datastore "events", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @itemsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @stringsDb = new Datastore "strings", (db) -> db.ensureIndex {random: '2dsphere'}, ->

    @loadItems()
    @loadGrammar()
    @loadPartyNames()

  loadGrammar: ->
    console.log "Loading grammar files..."
    @stringsDb.find
      type: "nouns"
    , (e, docs) ->
      console.log e if e
      Party::nouns = _.pluck docs, 'data'
    @stringsDb.find
      type: "prepositions"
    , (e, docs) ->
      console.log e if e
      Party::prepositions = _.pluck docs, 'data'
    @stringsDb.find
      type: "adjectives"
    , (e, docs) ->
      console.log e if e
      Party::adjectives = _.pluck docs, 'data'
    @stringsDb.find
      type: "articles"
    , (e, docs) ->
      console.log e if e
      Party::articles = _.pluck docs, 'data'
    @stringsDb.find
      type: "conjunctions"
    , (e, docs) ->
      console.log e if e
      Party::conjunctions = _.pluck docs, 'data'

  loadPartyNames: ->
    @stringsDb.find
      type: "party"
    , (e, docs) ->
      console.log e if e
      Party::partyNames = _.pluck docs, 'data'
    @stringsDb.find
      type: "partyGrammar"
    , (e, docs) ->
      console.log e if e
      Party::partyGrammar = _.pluck docs, 'data'

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
    @stringsDb.remove {}, {}, ->

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
        _.each data.toString().split("\n"), (line) => @insertStatic type, line

    stringstream = readdirp {root: "#{__dirname}/../../assets/data/strings", fileFilter: "*.txt"}
    stringstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @insertString type, line

  insertString: (type, string) ->
    return if not string
    @stringsDb.insert
      type: type
      data: string
      random: [Math.random(), 0]
    , ->

  insertYesNo: (question, y, n) ->
    @eventsDb.insert
      type: 'yesno'
      question: question
      y: y
      n: n
      random: [Math.random(), 0]
    , ->

  insertStatic: (type, remark) ->
    return if not remark
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