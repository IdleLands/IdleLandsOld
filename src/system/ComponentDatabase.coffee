
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "underscore"
_.str = require "underscore.string"
readdirp = require "readdirp"
fs = require "fs"
Party = require "../event/Party"

class ComponentDatabase

  itemStats: {}
  ingredientStats: {}
  monsters: []
  generatorCache: {}

  constructor: (@game) ->
    @eventsDb = new Datastore "events", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @itemsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @ingredientsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @analyticsDb = new Datastore "analytics", ->

    @importAllData()

  generateStringFromGrammar: (grammar) ->
    grammarPieces = grammar.split " "
    _.map grammarPieces, (piece) =>
      return piece if not _.str.include piece, "%"
      item = _.str.trim piece, "%"
      _.sample @generatorCache[item]
    .join " "

  _parseInitialArgs: (string) ->
    return [] if (_.str.isBlank string) or _.str.contains string, "#"
    string = _.str.clean string
    [string.split("\"")[1], string.split("\"")[2]?.trim()]

  _parseParameters: (baseObj, parameters) ->
    _.map (parameters.split ' '), (item) ->
      arr = item.split '='
      retval = {}
      testVal = parseInt arr[1]
      retval[arr[0]] = if _.isNaN testVal then arr[1] else testVal
      retval
    .reduce (cur, prev) ->
      _.extend prev, cur
    , baseObj

  parseMonsterString: (str) ->
    return if not _.str.contains str, "level"

    [name, parameters] = @_parseInitialArgs str
    return if not parameters

    parameters = @_parseParameters {name: name}, parameters

    @insertMonster parameters

  parseItemString: (str, type, retObj = no) ->
    [name, parameters] = @_parseInitialArgs str
    return if not parameters

    parameters = @_parseParameters { name: name, type: type }, parameters

    return parameters if retObj

    @insertItem parameters

  parseIngredientString: (str, type) ->
    [name, parameters] = @_parseInitialArgs str
    return if not parameters

    parameters = @_parseParameters { name: name, type: type }, parameters

    @insertIngredient parameters, ->

  importAllData: ->
    @itemsDb.remove {}, {}, ->
    @ingredientsDb.remove {}, {}, ->
    @eventsDb.remove {}, {}, ->

    stream = (path, callback) ->
      objStream = readdirp {root: path, fileFilter: "*.txt"}
      objStream
      .on "warn", (e) -> console.log "importAllData warning: #{e}"
      .on "error", (e) -> console.log "importAllData error: #{e}"
      .on "data", callback

    basePath = "#{__dirname}/../../assets/data"

    me = @

    stream "#{basePath}/items", (entry) ->
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) ->
        _.each data.toString().split("\n"), (line) -> me.parseItemString line, type

    stream "#{basePath}/ingredients", (entry) ->
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) ->
        _.each data.toString().split("\n"), (line) -> me.parseIngredientString line, type

    stream "#{basePath}/events", (entry) ->
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) ->
        _.each data.toString().split("\n"), (line) -> me.insertStatic type, line

    stream "#{basePath}/strings", (entry) ->
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) ->
        _.each data.toString().split("\n"), (line) -> me.insertString type, line

    stream "#{basePath}/monsters/", (entry) ->
      fs.readFile entry.fullPath, {}, (e, data) ->
        arr = data.toString().split("\n")
        _.each arr, (line) -> me.parseMonsterString line

  insertMonster: (monster) ->
    monster.random = [Math.random(), 0]
    monster.class = "Monster" if not monster.class
    monster.level = 1 if not monster.level
    monster.zone = "none" if not monster.zone
    @addMonsterToList monster

  insertString: (type, string) ->
    return if not string
    @generatorCache[type] = [] if not @generatorCache[type]
    @generatorCache[type].push string

  insertStatic: (type, remark) ->
    return if not remark
    @eventsDb.insert
      type: type
      remark: remark
      random: [Math.random(), 0]
    , ->
  
  insertIngredient: (object, duplicateCallback) ->
    copy = _.extend {}, object
    delete copy.name
    query = [ copy, {name: object.name} ]
    @ingredientsDb.findOne { $or: query }, (e, doc) =>

      if doc?.name is object.name
        duplicateCallback {name: doc.name}
        console.error "DUPLICATE INGREDIENT NAME: #{doc.name}"
        return
      else if doc
        console.error "DUPLICATE INGREDIENT STATS: #{doc.name}"
        duplicateCallback {stats: true}
        return

      @addIngredient object

  addItem: (object) ->

    @addItemToHash object

    object.random = [Math.random(), 0]
    @itemsDb.insert object, ->

  insertItem: (object) ->
    copy = _.extend {}, object
    delete copy.name
    query = [ copy, {name: object.name} ]
    @itemsDb.findOne { $or: query }, (e, doc) =>

      if doc?.name is object.name
        console.error "DUPLICATE ITEM NAME: #{doc.name}"
        return
      else if doc
        console.error "DUPLICATE ITEM STATS: #{doc.name}"
        return

      @addItem object

  addIngredient: (object) ->

    @addIngredientToHash object

    object.random = [Math.random(), 0]
    @ingredientsDb.insert object, ->

  getRandomEvent: (type, callback) ->
    @eventsDb.findOne
      type: type
      random:
        $near:
          $geometry:
            type: "Point"
            coordinates: [Math.random(), 0]
    , callback

  addItemToHash: (object) ->
    copy = _.extend {}, object

    if not (copy.type of @itemStats)
      @itemStats[copy.type] = []

    @itemStats[copy.type].push copy

  addIngredientToHash: (object) ->
    copy = _.extend {}, object

    if not (copy.type of @ingredientStats)
      @ingredientStats[copy.type] = []

    @ingredientStats[copy.type].push copy

  addMonsterToList: (monster) ->
    @monsters.push monster

  insertNewAnalyticsPoint: (player) ->
    @analyticsDb.insert player, (e) -> console.error e if e

module.exports = exports = ComponentDatabase