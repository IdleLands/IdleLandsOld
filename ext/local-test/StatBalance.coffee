
_ = require "lodash"
util = require "util"
MongoClient = require('mongodb').MongoClient

url = "mongodb://localhost:27017/idlelands"

baseStats = ['int', 'str', 'dex', 'con', 'wis', 'agi', 'luck', 'piety', 'sentimentality', 'ice', 'fire', 'water', 'earth', 'thunder']
baseSlots = ['body', 'charm', 'feet', 'finger', 'hands', 'head', 'legs', 'mainhand', 'neck', 'offhand', 'prefix-special', 'prefix', 'suffix']

minValue = -99999
maxValue = 99999

ignoredStats = []
ignoredSlots = []

stats = _.difference baseStats, ignoredStats
slots = _.difference baseSlots, ignoredSlots

actions = {}

addIndividualPropertyToGroup = (group, prop, action, val) ->
  group['$group'][prop] = {}
  group['$group'][prop]["$#{action}"] = val

addNameToGroup = (name) ->
  actions[name] = []
  [count, avg, min, max] = ["#{name}Count", "#{name}Avg", "#{name}Min", "#{name}Max"]

  newGroup = $group:
    _id: name

  addIndividualPropertyToGroup newGroup, name, 'sum', "$#{name}"
  addIndividualPropertyToGroup newGroup, count, 'sum', {$cond: [$eq: ["$#{name}", 0], 0, 1]}
  addIndividualPropertyToGroup newGroup, avg, 'avg', "$#{name}"
  addIndividualPropertyToGroup newGroup, min, 'min', "$#{name}"
  addIndividualPropertyToGroup newGroup, max, 'max', "$#{name}"

  matcher = '$match': {}
  matcher['$match'][name] =
    '$ne': 0
    '$gte': minValue
    '$lte': maxValue

  matcher['$match']['type'] =
    '$in': slots

  actions[name].push matcher
  actions[name].push newGroup

for stat in stats
  perc = "#{stat}Percent"

  addNameToGroup stat
  addNameToGroup perc

MongoClient.connect url, (e, db) ->
  console.error e if e

  itemsDb = db.collection 'items'

  for agg of actions
    itemsDb.aggregate actions[agg], (e, result) ->
      console.error e if e
      console.log result

  #process.exit()