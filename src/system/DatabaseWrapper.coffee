
fs = require 'fs'
Q = require 'q'
rimraf = require 'rimraf'

if fs.existsSync "#{__dirname}/../../config.json"
  config = require "#{__dirname}/../../config.json"
  databaseEngine = config.storage
  databaseURL = config.storageURL

#more info here: https://github.com/louischatriot/nedb/blob/master/README.md
Database = if databaseEngine is 'mongo' then require('mongodb').MongoClient else require 'nedb'

class DatabaseWrapper

  load: () =>
    if not @label?.length then throw new Error "Database must have a name."

    _isReady = Q.defer()
    @databaseReady = _isReady.promise

    if databaseEngine is 'mongo'
      if not DatabaseWrapper::databaseConnection
        Database.connect "mongodb://#{databaseURL}/idlelands", {server:{auto_reconnect:true}}, (e, db) =>
          #_isReady.error e if e?
          throw e if e?

          DatabaseWrapper::databaseConnection = db

          @db = DatabaseWrapper::databaseConnection.collection "#{@label}"

          @indexCallback?(@db)

          _isReady.resolve @db
      else
        @db = DatabaseWrapper::databaseConnection.collection "#{@label}"

      #use nedb by default because it's a better assumption to make
    else
      path = "data/#{@label}.ildb"
      @db = new Database { autoload: true, filename: path }
      _isReady.resolve @db

  insert: (data, callback) =>
    Q.when @databaseReady, () =>
      @db.insert data, callback

  remove: (query, options, callback) =>
    Q.when @databaseReady, =>
      if databaseEngine is 'mongo'
        @db.remove query, {w:0}
      else
        @db.remove query, options, callback

  findOne: (query, callback) =>
    Q.when @databaseReady, () =>
      @db.findOne query, callback

  count: (data, callback) =>
    Q.when @databaseReady, =>
      @db.count data, callback

  update: (query, update, options, callback) =>
    Q.when @databaseReady, =>
      @db.update query, update, options, callback

  find: (terms, callback) =>
    Q.when @databaseReady, =>
      if databaseEngine is 'mongo'
        @db.find terms, (e, docs) ->
          docs.toArray callback
      else
        @db.find terms, callback

  findForEach: (terms, callback) =>
    if databaseEngine is 'mongo'
      Q.when @databaseReady, =>
        @db.find(terms).stream().on 'data', (data) -> callback null, data
    else
      @db.find terms, (e, docs) ->
        docs.forEach (doc) ->
          callback e, doc

  ensureIndex: (data, index) =>
    Q.when @databaseReady, =>
      @db.ensureIndex data, index, ->

  aggregate: (query, callback) =>
    if databaseEngine is 'mongo'
      Q.when @databaseReady, =>
        @db.aggregate query, callback

  # Sorts documents by given properties to compare.
  # Each property in the object should either be
  # 1 for ascending or -1 for descending order.
  # Example compareProps = {name: 1, age: -1}
  # Will sort by name alphabetically, then age oldest first
  sort: (docs, compareProps) ->
    docs.sort (a, b) ->
      for prop, order of compareProps
        if a[prop] < b[prop]
          return -order
        if a[prop] > b[prop]
          return order
      return 0


  destroy: (callback) =>
    return if databaseEngine is 'mongo'
    callback ?= ->
    rimraf @db.filename, callback

  constructor: (@label, @indexCallback) ->
    @load()

module.exports = exports = DatabaseWrapper