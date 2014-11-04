
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

  constructor: (@game) ->
    @eventsDb = new Datastore "events", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @itemsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @ingredientsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @stringsDb = new Datastore "strings", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @monstersDb = new Datastore "monsters", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @analyticsDb = new Datastore "analytics", ->

    @importAllData()

  loadGrammar: ->
    _.each ["nouns", "prepositions", "adjectives", "articles", "conjunctions"], (type) =>
      @stringsDb.find
        type: type
      , (e, docs) ->
        console.log e if e
        Party::[type] = _.pluck docs, 'data'

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

  parseMonsterString: (str) ->
    return if (_.str.isBlank str) or _.str.contains str, "#"
    str = _.str.clean str
    [name, parameters] = [str.split("\"")[1], str.split("\"")[2]?.trim()]
    return if not parameters

    parameters = _.map (parameters.split ' '), (item) ->
      arr = item.split '='
      retval = {}
      testVal = parseInt arr[1]
      retval[arr[0]] = if _.isNaN testVal then arr[1] else testVal
      retval
    .reduce (cur, prev) ->
      _.extend prev, cur
    , { name: name }

    @insertMonster parameters

  parseItemString: (str, type, retObj = no) ->
    return if (_.str.isBlank str) or _.str.contains str, "#"
    str = _.str.clean str
    [name, parameters] = [str.split("\"")[1], str.split("\"")[2]?.trim()]
    return if not parameters

    parameters = _.map (parameters.split ' '), (item) ->
      arr = item.split '='
      retval = {}
      retval[arr[0]] = (parseInt arr[1]) ? null
      retval
    .reduce (cur, prev) ->
      _.extend prev, cur
    , { name: name, type: type }

    return parameters if retObj

    @insertItem parameters, ->

  parseIngredientString: (str, type) ->
    return if (_.str.isBlank str) or _.str.contains str, "#"
    str = _.str.clean str
    [name, parameters] = [str.split("\"")[1], str.split("\"")[2]?.trim()]
    return if not parameters

    parameters = _.map (parameters.split ' '), (item) ->
      arr = item.split '='
      retval = {}
      retval[arr[0]] = (parseInt arr[1]) ? null
      retval
    .reduce (cur, prev) ->
      _.extend prev, cur
    , { name: name, type: type }

    @insertIngredient parameters, ->

  importAllData: ->
    @itemsDb.remove {}, {}, ->
    @ingredientsDb.remove {}, {}, ->
    @eventsDb.remove {}, {}, ->
    @stringsDb.remove {}, {}, ->
    @monstersDb.remove {}, {}, ->

    itemstream = readdirp {root: "#{__dirname}/../../assets/data/items", fileFilter: "*.txt"}
    itemstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @parseItemString line, type

    ingredientstream = readdirp {root: "#{__dirname}/../../assets/data/ingredients", fileFilter: "*.txt"}
    ingredientstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      type = entry.name.split(".")[0]
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @parseIngredientString line, type

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

    monsterstream = readdirp {root: "#{__dirname}/../../assets/data/monsters", fileFilter: "*.txt"}
    monsterstream
    .on "warn", (e) -> console.log "importAllData warning: #{e}"
    .on "error", (e) -> console.log "importAllData error: #{e}"
    .on "data", (entry) =>
      fs.readFile entry.fullPath, {}, (e, data) =>
        _.each data.toString().split("\n"), (line) => @parseMonsterString line

  insertMonster: (monster) ->
    monster.random = [Math.random(), 0]
    monster.class = "Monster" if not monster.class
    monster.level = 1 if not monster.level
    monster.zone = "none" if not monster.zone
    @addMonsterToList monster
    @monstersDb.insert monster, ->

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
  
  insertIngredient: (object, duplicateCallback) ->
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

      @addIngredient object

  addItem: (object) ->

    @addItemToHash object

    object.random = [Math.random(), 0]
    @itemsDb.insert object, ->

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

  findEvent: (query, callback) ->
    @eventsDb.findOne query, callback

  removeEvent: (id, callback) ->
    @eventsDb.remove
      _id: ObjectID id
    , callback

  loadItems: ->
    @itemsDb.find {}, (e, docs) =>
      _.forEach docs, @addItemToHash.bind @

  addItemToHash: (object) ->
    copy = _.extend {}, object

    if not (copy.type of @itemStats)
      @itemStats[copy.type] = []

    @itemStats[copy.type].push copy

  loadIngredients: ->
    @ingredientsDb.find {}, (e, docs) =>
      _.forEach docs, @addIngredientToHash.bind @

  addIngredientToHash: (object) ->
    copy = _.extend {}, object

    if not (copy.type of @ingredientStats)
      @ingredientStats[copy.type] = []

    @ingredientStats[copy.type].push copy

  loadMonsters: ->
    @monstersDb.find {}, (e, docs) =>
      _.each docs, @addMonsterToList.bind @

  addMonsterToList: (monster) ->
    @monsters.push monster

  insertNewAnalyticsPoint: (player) ->
    @analyticsDb.insert player, (e) -> console.error e if e

module.exports = exports = ComponentDatabase