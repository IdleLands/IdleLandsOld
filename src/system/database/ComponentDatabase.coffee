
Datastore = require "./DatabaseWrapper"
ObjectID = require("mongodb").ObjectID
_ = require "lodash"
_.str = require "underscore.string"
readdirp = require "readdirp"
fs = require "fs"
Party = require "../../event/Party"
Q = require "q"

MessageCreator = require "../handlers/MessageCreator"

config = require "../../../config.json"

class ComponentDatabase

  itemStats: {}
  ingredientStats: {}
  monsters: []
  generatorCache: {}
  npcs: []

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
      retval[arr[0]] = if ((_.isNaN testVal) and (_.isUndefined arr[1])) then 1 else if arr[0] in ['class','gender','link','expiration'] then arr[1] else testVal
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

  parseNPC: (str) ->
    [name, parameters] = @_parseInitialArgs str
    paramObj = if parameters then @_parseParameters {name: name}, parameters else {name: name}
    @npcs.push paramObj

  importAllData: ->

    me = @

    itemDefer = Q.defer()
    ingredientDefer = Q.defer()
    eventDefer = Q.defer()
    stringDefer = Q.defer()
    monsterDefer = Q.defer()
    npcDefer = Q.defer()

    loadingItems = itemDefer.promise
    loadingIngredients = ingredientDefer.promise
    loadingEvents = eventDefer.promise
    loadingStrings = stringDefer.promise
    loadingMonsters = monsterDefer.promise
    loadingNpcs = npcDefer.promise

    stream = (path, callback) ->
      objStream = readdirp {root: path, fileFilter: "*.txt"}
      objStream
      .on "warn", (e) -> console.log "importAllData warning: #{e}"
      .on "error", (e) -> console.log "importAllData error: #{e}"
      .on "data", callback

    loadPath = (path) =>
      basePath = "#{__dirname}/../../../assets/#{path}"

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

      @eventsDb.remove {$not: [{type: "towncrier"}]}, {}, ->
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

      stream "#{basePath}/npcs/", (entry) ->
        fs.readFile entry.fullPath, {}, (e, data) ->
          arr = data.toString().split("\n")
          _.each arr, (line) -> me.parseNPC line

          npcDefer.resolve()

    loadPath "data"
    loadPath "custom" if fs.existsSync "#{__dirname}/../../../assets/custom"

    @loadingAll = Q.all [
      loadingItems
      loadingIngredients
      loadingEvents
      loadingStrings
      loadingMonsters
      loadingNpcs
    ]

  contentFolders:
    events: [
      "battle","blessGold","blessGoldParty","blessItem","blessXp","blessXpParty",
      "enchant","findItem","flipStat","forsakeGold","forsakeItem","forsakeXp","levelDown"
      "merchant","party","providence","tinker","towncrier"
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

    npcs: [
      "trainer"
    ]

    # here for posterity -- not currently submittable (partially due to conflicts w/ providence)
    strings: [
      "adjective", "article", "battleGrammar", "battleTitle", "conjunction", "noun", "partyGrammar"
      "preposition", "providence", "providenceGrammar"
    ]

  allValidTypes: -> @contentFolders.events.concat @contentFolders.ingredients.concat @contentFolders.items.concat @contentFolders.monsters.concat @contentFolders.npcs.concat @contentFolders.strings

  commitAndPushAllFiles: (types, submitters, moderator) ->
    #if not config.githubUser or not config.githubPass
    #  @game.errorHandler.captureException new Error "No githubUser or githubPass specified in config.json"
    #  return

    types = _.reject types, (type, i) ->
      if type is "towncrier"
        submitters[i] = null
        return yes
      no

    return if types.length is 0

    submitters = _.compact submitters

    repo = require("gitty") "#{__dirname}/../../../assets/custom"

    message = "New #{types.join ", "}\n\nThanks to #{submitters.join ", "}\n\nModerated by #{moderator}"

    repo.addSync ["."]
    repo.commitSync message
    repo.pull "origin", "master", {}

    repo.push "origin", "master", {###username: config.githubUser, password: config.githubPassword###}, ->

  writeNewContentToFile: (newItem) ->
    validFolders = ["events", "ingredients", "items", "monsters", "npcs"]

    _.each validFolders, (folder) =>
      return if not _.contains @contentFolders[folder], newItem.type
      fs.appendFileSync "#{__dirname}/../../../assets/custom/#{folder}/#{newItem.type}.txt", "#{newItem.content}\n"

  getContentList: ->
    defer = Q.defer()

    @submissionsDb.find {unAccepted: yes}, {}, (e, docs) ->
      defer.resolve {isSuccess: yes, code: 510, message: "Successfully retrieved custom content listing.", customs: docs}

    defer.promise

  rejectContent: (ids) ->
    oids = _.map ids, ObjectID

    defer = Q.defer()

    return Q {isSuccess: no, code: 505, message: "You didn't specify any targets."} if ids.length is 0

    @submissionsDb.remove {_id: {$in: oids}}, {multi: yes}, ->
      defer.resolve { isSuccess: yes, code: 504, message: "Successfully burninated #{ids.length} submissions." }

    defer.promise

  redeemGift: (identifier, crierId, giftId) ->
    defer = Q.defer()

    @eventsDb.findOne {_id: ObjectID(crierId), awardFor: {$elemMatch: {id: giftId}}, clicked: {$not: {$elemMatch: {id: giftId}}}}, (e, doc) =>
      return defer.resolve {isSuccess: no, code: 597, message: "That gift does not exist, or has already been redeemed!"} unless doc
      return defer.resolve {isSuccess: no, code: 596, message: "That gift is not redeemable!"} unless doc.gift and doc.gift > 0

      player = @game.playerManager.playerHash[identifier]
      player.addGold doc.gift
      defer.resolve {isSuccess: yes, code: 598, message: "Successfully claimed your gift of #{doc.gift} gold!"}
      @eventsDb.update {_id: ObjectID crierId}, {$push: {clicked: {player: identifier, id: giftId, click: new Date()}}}, ->

    defer.promise

  addPotentialGift: (id, user) ->
    @eventsDb.update {_id: ObjectID id}, {$push: {awardFor: user}}, ->

  lowerAdViewCount: (id, byCount = 1) ->
    @eventsDb.update {_id: ObjectID id}, {$inc: {views: -byCount}}, =>
      @removeBadOrOldAds()

  removeBadOrOldAds: ->
    expireOlderThan = new Date()
    @eventsDb.update {type: "towncrier", $or: [ {views: {$lte: 0}}, {expirationDate: {$lt: expireOlderThan}} ]}, {$set: {expiredOn: new Date()}}, ->

  putAdvertisementInDatabase: (ad) ->

    [message, parameters] = @_parseInitialArgs ad.content
    return unless parameters
    message = message.substring 0, 225
    parameters = @_parseParameters {message: message}, parameters

    parameters.random = [Math.random(), 0]
    _.extend parameters, ad

    parameters.clicked = []
    parameters.awardFor = []
    parameters.created = new Date()
    parameters.days = parameters.expiration or 30
    parameters.expirationDate = new Date()
    parameters.expirationDate.setDate parameters.expirationDate.getDate() + parameters.days
    parameters.setViews = parameters.views
    parameters.type = "towncrier"

    @eventsDb.insert parameters, ->

  approveContent: (ids, identifier) ->
    oids = _.map ids, ObjectID

    defer = Q.defer()

    return Q {isSuccess: no, code: 505, message: "You didn't specify any targets."} if ids.length is 0

    @submissionsDb.find {_id: {$in: oids}}, {}, (e, docs) =>

      return defer.resolve {isSuccess: no, code: 502, message: "None of those items are valid targets for approval."} if docs.length is 0

      _.each docs, (doc) =>

        if doc.type is "towncrier"
          @putAdvertisementInDatabase doc
          return

        @writeNewContentToFile doc
        @game.playerManager.incrementPlayerSubmissions doc.submitter

      @commitAndPushAllFiles (_.sortBy _.uniq _.pluck docs, "type"), (_.sortBy _.uniq _.pluck docs, "submitterName"), identifier

      @submissionsDb.update {_id: {$in: oids}}, {$set: {unAccepted: no}}, {multi: yes}, (e) ->
        defer.resolve {isSuccess: yes, code: 503, message: "Successfully approved #{docs.length} new items."}

    defer.promise

  testContent: (identifier, content) ->

    player = @game.playerManager.getPlayerById identifier
    return Q {isSuccess: no, code: 5123, message: "Invalid player."} unless player

    extra = {}

    testType = content.type?.toLowerCase()
    extra.xp = 5670 if _.contains testType, "xp"
    extra.gold = 10456 if _.contains testType, "gold"
    extra.item = (_.sample player.equipment).getName() if _.contains testType, "item"
    extra.stat = _.sample ['str', 'con', 'int', 'wis', 'dex', 'agi', 'luck']
    extra.partyName = 'Awesome Party Name'
    extra.partyMembers = 'Thing One, Thing Two, and Thing Three'

    text = MessageCreator._replaceMessageColors MessageCreator.doStringReplace content.content, player, extra

    Q {isSuccess: yes, code: 1000, message: text}

  submitCustomContent: (identifier, content) ->

    return Q {isSuccess: no, code: 500, message: "That type is invalid."} unless (content.type in @allValidTypes())

    player = @game.playerManager.playerHash[identifier]

    # only fire for unpaid events that are town crier
    if content.type is "towncrier" and -1 is content.content.indexOf "paid=1"
      [message, parameters] = @_parseInitialArgs content.content
      parsed = @_parseParameters {message: message}, parameters
      parsed.gift = +parsed.gift
      parsed.views = +parsed.views
      perPerson = if parsed.gift < 100 then 100 else parsed.gift+100
      views = if parsed.views < 100 then 100 else parsed.views
      cost = views*perPerson

      return Q {isSuccess: no, code: 500, message: "You don't have enough gold for that town crier statement. It costs a total of #{cost} gold. We have to pay him somehow!"} if player.gold.getValue() < cost

      player.takeGold cost

    content.submitterName = player.name
    content.submitter = identifier
    content.submissionTime = new Date()
    content.unAccepted = yes

    content.voters = {}
    content.voters[content.submitterName] = 1

    defer = Q.defer()

    insert = =>
      @submissionsDb.insert content, (e) =>
        @game.errorHandler.captureException e if e
        defer.resolve {isSuccess: yes, code: 501, message: "Successfully submitted new content!"}

    if content.type in ["body", "charm", "feet", "finger", "hands", "head", "legs", "mainhand", "neck", "offhand", "prefix", "suffix", "bread", "meat", "veg", "monster"]

      [name, parameters] = @_parseInitialArgs content.content

      if content.type is "monster"
        if _.findWhere @monsters, {name: name}
          defer.resolve {isSuccess: no, code: 1000, message: "That monster already exists!"}
        else
          insert()
      else
        if _.findWhere @itemStats[content.type], {name: name}
          defer.resolve {isSuccess: no, code: 1000, message: "\"#{name}\" already exists as a #{content.type}!"}
        else
          insert()

    else
      insert()

    defer.promise

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
        return
      else if doc
        @game.errorHandler.captureException new Error "DUPLICATE INGREDIENT STATS: #{doc.name}"
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
        return
      else if doc
        @game.errorHandler.captureException new Error "DUPLICATE ITEM STATS: #{doc.name}"
        return

      @addItem object

  addIngredient: (object) ->

    @addIngredientToHash object

    object.random = [Math.random(), 0]
    @ingredientsDb.insert object, ->

  getRandomEvent: (type, extra = {}, callback) ->
    opts =
      type: type
      random:
        $near:
          $geometry:
            type: "Point"
            coordinates: [Math.random(), 0]

    _.extend opts, extra
    @eventsDb.findOne opts, callback

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
    @analyticsDb.insert player, ->
      # I'd catch this exception, but it's not one that needs to be caught
      # All it is, is a duplicate insertion error

module.exports = exports = ComponentDatabase
