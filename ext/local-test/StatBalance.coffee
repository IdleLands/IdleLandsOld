
_ = require "underscore"
MongoClient = require('mongodb').MongoClient

url = "mongodb://localhost:27017/idlelands"

baseStats = ['int', 'str', 'dex', 'con', 'wis', 'agi', 'luck', 'piety', 'sentimentality', 'ice', 'fire', 'water', 'earth', 'thunder']

action = 'sum' # avg, count
min = -99999
max = 99999

ignoredStats = []

stats = _.difference baseStats, ignoredStats

group =
  $group:
    _id: null

for i in stats
  perc = "#{i}Percent"

  group['$group'][i] = {}
  group['$group'][perc] = {}

  group['$group'][i]["$#{action}"] = "$#{i}"
  group['$group'][perc]["$#{action}"] = "$#{perc}"

MongoClient.connect url, (e, db) ->
  console.error e if e

  itemsDb = db.collection 'items'

  itemsDb.aggregate [
    group
  ], (e, result) ->
    console.error e if e
    console.log result

    process.exit()