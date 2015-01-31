
Datastore = require "./../database/DatabaseWrapper"
_ = require "lodash"
Equipment = require "../../item/Equipment"
Q = require "q"
MessageCreator = require "./../handlers/MessageCreator"
RestrictedNumber = require "restricted-number"
Constants = require "./../utilities/Constants"
PetData = require "../../../config/pets.json"
Pet = require "../../character/npc/Pet"

class PetManager

  pets: []
  activePets: {}

  constructor: (@game) ->
    @db = new Datastore "pets", (db) ->
      db.ensureIndex { createdAt: 1 }, { unique: true }, ->

    @db.findForEach {}, @loadPet, @

    @logger = @game.logManager.getLogger "PetManager"
    @DELAY_INTERVAL = 10000
    @beginGameLoop()

  beginGameLoop: ->
    setInterval =>
      arr = _.keys @activePets
      _.each arr, (player, i) =>
        pet = @activePets[player]
        setTimeout (pet?.takeTurn.bind pet), @DELAY_INTERVAL/arr.length*i

    , @DELAY_INTERVAL

  getActivePetFor: (player) ->
    @logger?.debug "getActivePetFor parameters", {identifier: player.identifier}
    @logger?.silly "getActivePetFor parameters", {identifier: player}
    @logger?.verbose "getActivePetFor result", {pet: @activePets[player.identifier]}

    @activePets[player.identifier]

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

    newPet = new Pet options
    @pets.push newPet
    newPet.petManager = @
    @configurePet newPet
    @handleSoul newPet

    player.foundPets[type].purchaseDate = Date.now()
    player.foundPets[type].uid = newPet.createdAt

    @changePetForPlayer player, newPet

  verifyAndCorrectPet: (pet) ->
    # reset stats to max value if they go over
    for stat, value of pet.scaleLevel
      pet.scaleLevel[stat] = Math.min value, PetData[pet.type].scale[stat].length-1

    # unequip all items in an invalid or over-filled slot
    currentlyEquipped = _.countBy pet.equipment, 'type'
    for slot, max of PetData[pet.type].slots
      if currentlyEquipped[slot] > max
        items = _.filter pet.equipment, (item) -> item.type is slot
        _.each items, (item) -> pet.unequip item

    # sell items that are overflowing the inventory
    itemsOverMax = PetData[pet.type].scale.inventory[pet.scaleLevel.inventory] - pet.inventory.length
    if itemsOverMax < 0
      sellItems = pet.inventory[0...Math.abs itemsOverMax]
      _.each sellItems, (item) ->
        pet.sellItem item, no
        pet.removeFromInventory item

  loadPet: (pet) ->
    pet.petManager = @
    @pets.push pet
    @activePets[pet.owner.identifier] = pet if pet.isActive
    pet.__proto__ = Pet.prototype

    loadRN = (obj) ->
      return if not obj
      obj.__current = 0 if _.isNaN obj.__current
      obj.__proto__ = RestrictedNumber.prototype
      obj

    loadProfession = (professionName) ->
      new (require "../../character/classes/#{professionName}")()

    loadEquipment = (equipment, autoequip = no) ->
      _.forEach equipment, (item) ->
        item.__proto__ = Equipment.prototype
        pet.addToEquippedBy item if autoequip

    _.forEach ['hp', 'mp', 'special', 'level', 'xp', 'gold'], (item) ->
      pet[item] = loadRN pet[item]

    pet.loadCalc()
    pet.equipment = loadEquipment pet.equipment, yes
    pet.inventory = loadEquipment pet.inventory
    pet.special.name = ''
    pet.profession = loadProfession pet.professionName

    @handleSoul pet

    @configurePet pet

    @verifyAndCorrectPet pet

    pet.recalculateStats()

    pet.setMaxListeners 0

  handleSoul: (pet) ->
    petSoul = _.findWhere pet.equipment, {type: 'pet soul'}
    pet.equipment = _.without pet.equipment, petSoul

    baseSoul = _.clone PetData[pet.type].specialStats
    baseSoul.itemFindRangeMultiplier = _.clone PetData[pet.type].scale.itemFindRangeMultiplier
    baseSoul.name = "Pet Soul"
    baseSoul.type = "pet soul"
    baseSoul.itemClass = "basic"

    pet.equipment.push new Equipment baseSoul

  save: (pet) ->
    @db.update {createdAt: pet.createdAt}, pet, {upsert: yes}, (e) =>
      @game.errorHandler.captureException e if e

  getPetsForPlayer: (identifier) ->
    @logger?.debug "getPetsForPlayer parameters", {identifier: identifier}

    filteredPets = _.filter @pets, (pet) -> pet.owner.identifier is identifier
    ret = _.map filteredPets, (pet) -> pet.buildSaveObject()

    @logger?.silly "getPetsForPlayer result", {pets: ret}

    ret

  changePetForPlayer: (player, newPet) ->
    @activePets[player.identifier]?.isActive = no
    @activePets[player.identifier]?.save()
    @activePets[player.identifier] = newPet
    @activePets[player.identifier].isActive = yes
    newPet.updateItemFind()

  canUsePet: (pet, player) ->
    requirements = pet.requirements

    meets = yes

    _.each requirements.collectibles, (collectible) -> meets = no if not _.findWhere player.collectibles, {name: collectible}
    _.each requirements.achievements, (achievement) -> meets = no if not _.findWhere player.achievements, {name: achievement}
    _.each requirements.bosses,              (boss) -> meets = no if not player.statistics?['calculated boss kills']?[boss]
    _.each (_.keys requirements.statistics), (stat) -> meets = no if not player.statistics?[stat] or player.statistics[stat] < requirements.statistics[stat]

    meets

  handlePetsForPlayer: (player) ->
    @checkPetAvailablity player

  configurePet: (pet) ->
    config = @getConfig pet

    pet._configCache = config

    _.each (_.keys config.scaleCost), (key) ->
      pet.scaleLevel[key] = 0 if not pet.scaleLevel[key]

    pet.level.maximum = config.scale.maxLevel[pet.scaleLevel.maxLevel]
    pet.gold.maximum = config.scale.goldStorage[pet.scaleLevel.goldStorage]

    pet.inventory = [] if not pet.inventory

    pet.calc.itemFindRange()

  getConfig: (pet) ->
    PetData[pet.type]

  buildPetSaveObject: (pet) ->
    realCalc = _.omit pet.calc, 'self'
    calc = realCalc.base
    calcStats = realCalc.statCache
    badStats = [
      'petManager'
      'party'
      'personalities'
      'identifier'
      'calc'
      'spellsAffectedBy'
      'fled'
      '_events'
      'profession'
      '_id'
    ]
    ret = _.omit pet, badStats
    ret._baseStats = calc
    ret._statCache = calcStats
    ret

  checkPetAvailablity: (player) ->
    player.foundPets = {} if not player.foundPets
    for key,val of PetData
      continue if player.foundPets[key] or not @canUsePet val, player

      @game.eventHandler.broadcastEvent
        player: player
        sendMessage: yes
        type: "pet"
        message: "<player.name>#{player.getName()}</player.name> has unlocked a new pet: <player.name>#{key}</player.name>"

      player.foundPets[key] =
        cost: PetData[key].cost
        purchaseDate: null
        unlockDate: Date.now()

module.exports = exports = PetManager
