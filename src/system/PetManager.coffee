
Datastore = require "./DatabaseWrapper"
_ = require "underscore"
Equipment = require "../item/Equipment"
Q = require "q"
MessageCreator = require "./MessageCreator"
Constants = require "./Constants"
PetData = require "../../config/pets.json"

class PetManager

  pets: []
  activePets: {}

  constructor: (@game) ->
    @db = new Datastore "pets", (db) =>
      db.findForEach {}, @loadPet

    @interval = null
    @DELAY_INTERVAL = 1000
    @beginGameLoop()

  beginGameLoop: ->

      setInterval =>
        arr = _.keys @activePets
        _.each arr, (player, i) =>
          pet = @activePets[player]
          setTimeout pet.takeTurn, @DELAY_INTERVAL/arr.length*i

      , @DELAY_INTERVAL

  createPet: (options) ->
    {player, type, name, attr1, attr2} = options

    options =
      name: name
      attrs: [attr1, attr2]
      type: type

      owner:
        identifier: player.identifier
        name: player.name

      creator:
        identifier: player.identifier
        name: player.name

  loadPet: (pet) ->
    console.log pet

  save: (pet) ->
    @db.update {_id: pet._id}, pet, {upsert: yes}

  canUsePet: (pet, player) ->
    requirements = pet.requirements

    meets = yes

    _.each requirements.collectibles, (collectible) -> meets = no if not _.findWhere player.collectibles, {name: collectible}
    _.each requirements.achievements, (achievement) -> meets = no if not _.findWhere player.achievements, {name: achievement}
    _.each requirements.bosses,              (boss) -> meets = no if not (boss of player.statistics['calculated boss kills'])
    _.each (_.keys requirements.statistics), (stat) -> meets = no if player.statistics[stat] < requirements.statistics[stat]

    meets

  handlePetsForPlayer: (player) ->
    @checkPetAvailablity player

  checkPetAvailablity: (player) ->
    player.foundPets = {} if not player.foundPets
    for key,val of PetData
      continue if player.foundPets[key] or not @canUsePet val, player

      @game.eventHandler.broadcastEvent
        player: player
        sendMessage: yes
        type: "pet"
        message: "<player.name>#{player.name}</player.name> has unlocked a new pet: <player.name>#{key}</player.name>"

      player.foundPets[key] =
        cost: PetData[key].cost
        purchaseDate: null
        unlockDate: Date.now()

module.exports = exports = PetManager