
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "lodash"
_.str = require "underscore.string"
readdirp = require "readdirp"
fs = require "fs"
Party = require "../event/Party"
Q = require "q"

config = require "../../config.json"

class ComponentDatabase

  itemStats: {}
  ingredientStats: {}
  monsters: []
  generatorCache: {}

  constructor: (@game) ->
    @eventsDb = new Datastore "events", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @itemsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @ingredientsDb = new Datastore "items", (db) -> db.ensureIndex {random: '2dsphere'}, ->
    @battleDb = new Datastore "battles", (db) -> db.ensureIndex {started: 1}, {expireAfterSeconds: 10800}, ->
    @analyticsDb = new Datastore "analytics", (db) -> db.ensureIndex {identifier: 1, 'level.__current': 1}, {unique: yes}, ->
    @submissionsDb = new Datastore "submissions", ->

    @importAllData()

  insertBattle: (battle, callback) ->
    @battleDb.insert battle, callback

  retrieveBattle: (battleId) ->
    defer = Q.defer()
    @battleDb.findOne {_id: ObjectID battleId}, (e, doc) =>
      @game.errorHandler.captureException e if e
      defer.resolve {isSuccess: no, code: 120, message: "Battle not found."} if e or not doc
      defer.resolve {isSuccess: yes, code: 121, message: "Battle retrieved.", battle: doc}

    defer.promise

  generatePartyName: ->
    @generateStringFromGrammar _.sample @generatorCache.partyGrammar

  generateBattleName: ->
    @generateStringFromGrammar _.sample @generatorCache.battleGrammar

  generateProvidenceName: ->
    @generateStringFromGrammar _.sample @generatorCache.providenceGrammar

  generateStringFromGrammar: (grammar) ->
    return "" if not grammar
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
      retval[arr[0]] = if ((_.isNaN testVal) and (_.isUndefined arr[1])) then 1 else if arr[0] is 'class' then arr[1] else testVal
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

    me = @

    itemDefer = Q.defer()
    ingredientDefer = Q.defer()
    eventDefer = Q.defer()
    stringDefer = Q.defer()
    monsterDefer = Q.defer()

    loadingItems = itemDefer.promise
    loadingIngredients = ingredientDefer.promise
    loadingEvents = eventDefer.promise
    loadingStrings = stringDefer.promise
    loadingMonsters = monsterDefer.promise

    stream = (path, callback) ->
      objStream = readdirp {root: path, fileFilter: "*.txt"}
      objStream
      .on "warn", (e) -> console.log "importAllData warning: #{e}"
      .on "error", (e) -> console.log "importAllData error: #{e}"
      .on "data", callback

    loadPath = (path) =>
      basePath = "#{__dirname}/../../assets/#{path}"

      @itemsDb.remove {}, {}, ->
        stream "#{basePath}/items", (entry) ->
          type = entry.name.split(".")[0]
          fs.readFile entry.fullPath, {}, (e, data) ->
            _.each data.toString().split("\n"), (line) -> me.parseItemString line, type

          itemDefer.resolve()

      @ingredientsDb.remove {}, {}, ->
        stream "#{basePath}/ingredients", (entry) ->
          type = entry.name.split(".")[0]
          fs.readFile entry.fullPath, {}, (e, data) ->
            _.each data.toString().split("\n"), (line) -> me.parseIngredientString line, type

          ingredientDefer.resolve()

      @eventsDb.remove {}, {}, ->
        stream "#{basePath}/events", (entry) ->
          type = entry.name.split(".")[0]
          fs.readFile entry.fullPath, {}, (e, data) ->
            _.each data.toString().split("\n"), (line) -> me.insertStatic type, line

          eventDefer.resolve()

      stream "#{basePath}/strings", (entry) ->
        type = entry.name.split(".")[0]
        fs.readFile entry.fullPath, {}, (e, data) ->
          _.each data.toString().split("\n"), (line) -> me.insertString type, line

        stringDefer.resolve()

      stream "#{basePath}/monsters/", (entry) ->
        fs.readFile entry.fullPath, {}, (e, data) ->
          arr = data.toString().split("\n")
          _.each arr, (line) -> me.parseMonsterString line

          monsterDefer.resolve()

    loadPath "data"
    loadPath "custom" if fs.existsSync "#{__dirname}/../../assets/custom"

    @loadingAll = Q.all [
      loadingItems
      loadingIngredients
      loadingEvents
      loadingStrings
      loadingMonsters
    ]

  contentFolders:
    events: [
      "battle","blessGold","blessGoldParty","blessItem","blessXp","blessXpParty",
      "enchant","findItem","flipStat","forsakeGold","forsakeItem","forsakeXp","levelDown"
      "merchant","party","providence","tinker"
    ]

    ingredients: [
      "bread", "veg", "meat"
    ]

    items: [
      "body", "charm", "feet", "finger", "hands", "head", "legs", "mainhand", "neck", "offhand"
      "prefix", "prefix-special", "suffix"
    ]

    monsters: [
      "monster"
    ]

    # here for posterity -- not currently submittable (partially due to conflicts w/ providence)
    strings: [
      "adjective", "article", "battleGrammar", "battleTitle", "conjunction", "noun", "partyGrammar"
      "preposition", "providence", "providenceGrammar"
    ]

  allValidTypes: -> @contentFolders.events.concat @contentFolders.ingredients.concat @contentFolders.items.concat @contentFolders.monsters.concat @contentFolders.strings

  commitAndPushAllFiles: (types, submitters) ->
    #if not config.githubUser or not config.githubPass
    #  @game.errorHandler.captureException new Error "No githubUser or githubPass specified in config.json"
    #  return

    repo = require("gitty") "#{__dirname}/../../assets/custom"

    message = "New #{types.join ", "}\n\nThanks to #{submitters.join ", "}"

    repo.addSync ["."]
    repo.commitSync message

    repo.push "origin", "master", {###username: config.githubUser, password: config.githubPassword###}, ->

  writeNewContentToFile: (newItem) ->
    validFolders = ["events", "ingredients", "items", "monsters"]

    _.each validFolders, (folder) =>
      return if not _.contains @contentFolders[folder], newItem.type
      fs.appendFileSync "#{__dirname}/../../assets/custom/#{folder}/#{newItem.type}.txt", "#{newItem.content}\n"

  getContentList: ->
    defer = Q.defer()

    @submissionsDb.find {}, (e, docs) ->
      defer.resolve {isSuccess: yes, code: 510, message: "Successfully retrieved custom content listing.", customs: docs}

    defer.promise

  rejectContent: (ids) ->
    oids = _.map ids, ObjectID

    defer = Q.defer()

    return Q {isSuccess: no, code: 505, message: "You didn't specify any targets."} if ids.length is 0

    @submissionsDb.remove {_id: {$in: oids}}, {multi: yes}, ->
      defer.resolve { isSuccess: yes, code: 504, message: "Successfully burninated #{ids.length} submissions." }

    defer.promise

  approveContent: (ids) ->
    oids = _.map ids, ObjectID

    defer = Q.defer()

    return Q {isSuccess: no, code: 505, message: "You didn't specify any targets."} if ids.length is 0

    @submissionsDb.find {_id: {$in: oids}}, (e, docs) =>

      return defer.resolve { isSuccess: no, code: 502, message: "None of those items are valid targets for approval." } if docs.length is 0

      _.each docs, (doc) =>
        @writeNewContentToFile doc
        @game.playerManager.incrementPlayerSubmissions doc.submitter

      @commitAndPushAllFiles (_.sortBy _.uniq _.pluck docs, "type"), (_.sortBy _.uniq _.pluck docs, "submitterName")

      @submissionsDb.remove {_id: {$in: oids}}, {multi: yes}, (e) ->
        defer.resolve isSuccess: yes, code: 503, message: "Successfully approved #{docs.length} new items."

    defer.promise

  submitCustomContent: (identifier, content) ->

    return Q {isSuccess: no, code: 500, message: "That type is invalid."} if not (content.type in @allValidTypes())

    content.submitterName = @game.playerManager.playerHash[identifier].name
    content.submitter = identifier
    content.submissionTime = new Date()

    content.voters = {}
    content.voters[identifier] = 1

    @submissionsDb.insert content, ->

    Q {isSuccess: yes, code: 501, message: "Successfully submitted new content!"}

  insertMonster: (monster) ->
    monster.random = [Math.random(), 0]
    monster.class = "Monster" if not monster.class
    monster.level = 1 if not monster.level
    monster.zone = "none" if not monster.zone
    @addMonsterToList monster

  insertString: (type, string) ->
    return if not string
    @generatorCache[type] = [] if not @generatorCache[type]
    @generatorCache[type].push _.str.trim string

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

      @game.errorHandler.captureException e if e

      if doc?.name is object.name
        duplicateCallback {name: doc.name}
        @game.errorHandler.captureMessage "DUPLICATE INGREDIENT NAME: #{doc.name}"
        return
      else if doc
        @game.errorHandler.captureMessage "DUPLICATE INGREDIENT STATS: #{doc.name}"
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

      @game.errorHandler.captureException e if e

      if doc?.name is object.name
        @game.errorHandler.captureMessage "DUPLICATE ITEM NAME: #{doc.name}"
        return
      else if doc
        @game.errorHandler.captureMessage "DUPLICATE ITEM STATS: #{doc.name}"
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
    @analyticsDb.insert player, (e) =>
      @game.errorHandler.captureException e if e

module.exports = exports = ComponentDatabase
