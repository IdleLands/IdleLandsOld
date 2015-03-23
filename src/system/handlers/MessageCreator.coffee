
_ = require "lodash"
_.str = require "underscore.string"
API = require "./../accessibility/API"

chance = new (require "chance")()

requireDir = require "require-dir"

getCD = -> API.gameInstance.componentDatabase

class RandomDomainHandler

  ##TAG:EVENTVAR_DYNAMIC: $random:placeholder$ | A random piece of placeholder text
  placeholder = @placeholder = -> CustomHandler.dict [funct: 'placeholder']

  ##TAG:EVENTVAR_DYNAMIC: $random:town$ | A random town name
  @town = ->
    _.sample _.filter API.gameInstance.world.uniqueRegions, (str) -> _.contains str, 'Town'

  ##TAG:EVENTVAR_DYNAMIC: $random:class$ | A random class name
  @class = ->
    # can't be precalculated because the game throws errors, of course.
    (_.sample _.keys requireDir "../../character/classes") or placeholder()

  ##TAG:EVENTVAR_DYNAMIC: $random:pet$ | A random pet name
  @pet = ->
    (_.sample API.gameInstance.petManager.pets)?.name or placeholder()

  ##TAG:EVENTVAR_DYNAMIC: $random:activePet$ | A random, active pet name
  @activePet = ->
    petHash = API.gameInstance.petManager.activePets
    petHash[_.sample _.keys petHash]?.name or placeholder()

  ##TAG:EVENTVAR_DYNAMIC: $random:player$ | A random player name
  @player = ->
    (_.sample API.gameInstance.playerManager.players)?.name or placeholder()

  ##TAG:EVENTVAR_DYNAMIC: $random:guild$ | A random guild name
  @guild = ->
    (_.sample API.gameInstance.guildManager.guilds)?.name or placeholder()

  ##TAG:EVENTVAR_DYNAMIC: $random:map$ | A random map name
  @map = ->
    _.sample _.keys API.gameInstance.world.maps

  ##TAG:EVENTVAR_DYNAMIC: $random:item$ | A random item
  ##TAG:EVENTVAR_DYNAMIC: $random:item:{'type':itemType}$ | A random item of the type itemType
  @item = (args) ->
    type = args?.type or (_.sample _.keys getCD().itemStats)
    (_.sample getCD().itemStats[type])?.name or placeholder() #should only happen locally

  ##TAG:EVENTVAR_DYNAMIC: $random:monster$ | A random monster name
  @monster = ->
    (_.sample getCD().monsters)?.name or placeholder() #should only happen locally

  ##TAG:EVENTVAR_DYNAMIC: $random:ingredient$ | A random ingredient
  ##TAG:EVENTVAR_DYNAMIC: $random:ingredient:{'type':ingType}$ | A random ingredient of the type ingType
  @ingredient = (args) ->
    type = args?.type or (_.sample _.keys getCD().ingredientStats)
    (_.sample getCD().ingredientStats[type])?.name or placeholder() # should only happen locally

  ##TAG:EVENTVAR_DYNAMIC: $combat:party$ | A random party name
  ##TAG:EVENTVAR_DYNAMIC: $combat:party party:member$ | A random member from a random party
  @party = (args, props, varCache, parties) ->
    {domain, funct, cacheNum} = props[0]

    party = varCache[domain]?[funct]?[cacheNum] ? if _.isNaN cacheNum then _.sample parties else parties[cacheNum]

    varCache[domain] = {} if not varCache[domain]
    varCache[domain][funct] = [] if not varCache[domain][funct]
    varCache[domain][funct][cacheNum] = party if not _.isNaN cacheNum

    partyName = party?.name or "A Group Of Adventurers"

    return partyName if not props[1]
    {cacheNum} = props[1]

    return "A Mysterious Adventurer" if not party

    if _.isNaN cacheNum then (_.sample party.players).name else party.players[cacheNum]?.name or "A Mysterious Adventurer"

class CustomHandler

  ##TAG:EVENTVAR_DYNAMIC: $dict:adjective$ | A random adjective
  ##TAG:EVENTVAR_DYNAMIC: $dict:noun$ | A random, lowercase noun
  ##TAG:EVENTVAR_DYNAMIC: $dict:nouns$ | A random, lowercase, plural noun
  ##TAG:EVENTVAR_DYNAMIC: $dict:article$ | A random article
  ##TAG:EVENTVAR_DYNAMIC: $dict:conjunction$ | A random conjunction
  ##TAG:EVENTVAR_DYNAMIC: $dict:preposition$ | A random preposition

  ##TAG:EVENTVAR_DYNAMIC: $dict:Adjective$ | A random, uppercase adjective
  ##TAG:EVENTVAR_DYNAMIC: $dict:Noun$ | A random, uppercase noun
  ##TAG:EVENTVAR_DYNAMIC: $dict:Nouns$ | A random, uppercase, plural noun
  ##TAG:EVENTVAR_DYNAMIC: $dict:Article$ | A random, uppercase article
  ##TAG:EVENTVAR_DYNAMIC: $dict:Conjunction$ | A random, uppercase conjunction
  ##TAG:EVENTVAR_DYNAMIC: $dict:Preposition$ | A random, uppercase preposition

  ##TAG:EVENTVAR_DYNAMIC: $dict:deity$ | A random deity and their flavor text
  @dict = (props) ->
    {funct} = props[0]
    realFunct = funct.toLowerCase()

    if realFunct is "nouns"
      realFunct = "noun"
      isPlural = yes

    canLowercase = (funct) ->
      funct isnt "deity"

    value = _.sample getCD().generatorCache[realFunct]
    if canLowercase funct
      value = if funct.toLowerCase() is funct then value.toLowerCase() else _.str.capitalize value

    value = value.substring 0, value.length-1 if realFunct is "noun" and not isPlural #all nouns end in 's'

    value

  @chance = (props) ->
    {funct, args} = props[0]
    chance[funct]? args

  @combat = (props, cache) ->
    {funct, args} = props[0]
    RandomDomainHandler[funct]? args, props, cache, API.gameInstance._battleParties

  @random = (props, cache) ->
    {funct, args} = props[0]
    RandomDomainHandler[funct]? args, props, cache, API.gameInstance.parties

class OwnedDomainHandler
  @pet = (player) ->
    petText = RandomDomainHandler.placeholder()

    if player?.playerManager
      pet = player.playerManager.game.petManager.getActivePetFor player
      petText = pet.getName() if pet

    petText

  @guild = (player) ->
    if player?.guild then player.guild else RandomDomainHandler.guild()

  @guildMember = (player) ->
    randomPlayer = RandomDomainHandler.player()

    members = (player?.playerManager?.game.guildManager.getGuildByName player?.guild)?.members
    return randomPlayer if not members or members.length is 1

    (_.sample (_.filter members, (member) -> member.name isnt player.name)).name

class MessageCreator

  defaultReplaceFunction = (msg) -> msg

  defaultColorMap =
    colorMap =
      "player.name":                defaultReplaceFunction
      "event.partyName":            defaultReplaceFunction
      "event.partyMembers":         defaultReplaceFunction
      "event.player":               defaultReplaceFunction
      "event.damage":               defaultReplaceFunction
      "event.gold":                 defaultReplaceFunction
      "event.realGold":             defaultReplaceFunction
      "event.shopGold":             defaultReplaceFunction
      "event.xp":                   defaultReplaceFunction
      "event.realXp":               defaultReplaceFunction
      "event.percentXp":            defaultReplaceFunction
      "event.item.newbie":          defaultReplaceFunction
      "event.item.Normal":          defaultReplaceFunction
      "event.item.basic":           defaultReplaceFunction
      "event.item.pro":             defaultReplaceFunction
      "event.item.idle":            defaultReplaceFunction
      "event.item.godly":           defaultReplaceFunction
      "event.item.custom":          defaultReplaceFunction
      "event.item.guardian":        defaultReplaceFunction
      "event.finditem.scoreboost":  defaultReplaceFunction
      "event.finditem.perceived":   defaultReplaceFunction
      "event.finditem.real":        defaultReplaceFunction
      "event.blessItem.stat":       defaultReplaceFunction
      "event.blessItem.value":      defaultReplaceFunction
      "event.flip.stat":            defaultReplaceFunction
      "event.flip.value":           defaultReplaceFunction
      "event.enchant.boost":        defaultReplaceFunction
      "event.enchant.stat":         defaultReplaceFunction
      "event.tinker.boost":         defaultReplaceFunction
      "event.tinker.stat":          defaultReplaceFunction
      "event.transfer.destination": defaultReplaceFunction
      "event.transfer.from":        defaultReplaceFunction
      "player.class":               defaultReplaceFunction
      "player.level":               defaultReplaceFunction
      "stats.hp":                   defaultReplaceFunction
      "stats.mp":                   defaultReplaceFunction
      "stats.sp":                   defaultReplaceFunction
      "damage.hp":                  defaultReplaceFunction
      "damage.mp":                  defaultReplaceFunction
      "spell.turns":                defaultReplaceFunction
      "spell.spellName":            defaultReplaceFunction
      "event.casterName":           defaultReplaceFunction
      "event.spellName":            defaultReplaceFunction
      "event.targetName":           defaultReplaceFunction
      "event.achievement":          defaultReplaceFunction
      "event.guildName":            defaultReplaceFunction

  @replaceMessageColors: (message) ->
    @_replaceMessageColors message, _.defaults (@colorMap or {}), defaultColorMap

  @_replaceMessageColors: (message, map = defaultColorMap) ->

    for search, replaceFunc of map
      regexp = new RegExp "(<#{search}>)([\\s\\S]*?)(<\\/#{search}>)", "g"
      message = message.replace regexp, (match, p1, p2) ->
        replaceFunc p2

    message

  @genericMessage: (message) ->
    return if not message
    @replaceMessageColors message

  @registerMessageMap: (@colorMap) ->
    console.log "Registered color map."

  getGenderPronoun = (gender, replace) ->
    switch replace
      when '%hisher'
        if gender is 'male' then 'his'
        else if gender is 'female' then 'her'
        else 'their'

      when '%hishers'
        if gender is 'male' then 'his'
        else if gender is 'female' then 'hers'
        else 'theirs'

      when '%himher'
        if gender is 'male' then 'him'
        else if gender is 'female' then 'her'
        else 'them'

      when '%she'
        if gender is 'male' then 'he'
        else if gender is 'female' then 'she'
        else 'they'

  @handleCustomVariables = (string) ->
    varCache = {}

    getCache = (domain, funct, cacheNum) ->
      varCache[domain][funct][cacheNum]

    setCache = (domain, funct, cacheNum, retVal) ->
      varCache[domain] = {} if not varCache[domain]
      varCache[domain][funct] = [] if not varCache[domain][funct]
      varCache[domain][funct][cacheNum] = retVal if not _.isNaN cacheNum

    getVarProps = (keyString) ->
      terms = keyString.split " "
      varProps = []
      _.each terms, (term) ->
        [props, cacheNum] = term.split "#"
        [domain, funct] = props.split ":", 2
        args = (_.str.trim props.substring 1+funct.length+props.indexOf funct).split("'").join '"'
        try
          varProps.push
            domain: domain
            funct: funct
            args: if args then JSON.parse args
            cacheNum: parseInt cacheNum
        catch e
          API.gameInstance.errorHandler.captureException e, extra: message: keyString

      varProps

    transformVarProps = (props) ->
      {domain, funct, cacheNum} = props[0]

      return getCache domain, funct, cacheNum if funct isnt 'party' and (not _.isNaN cacheNum) and varCache[domain]?[funct]?[cacheNum]

      retVal = CustomHandler[domain]? props, varCache

      setCache domain, funct, cacheNum, retVal if funct isnt 'party'   #let party handle caching by itself because it has to do nested weird shit

      retVal

    string.replace /\$([a-zA-Z\:#0-9 {}_,']+)\$/g, (match, p1, p2) ->
      transformVarProps getVarProps p1

  @doStringReplace: (string, player = {}, extra = {}) ->
    gender = player?.getGender()
    string = _.str.clean string

    (string = string.split("%#{key}").join (if key is "item" then val else "<event.#{key}>#{val}</event.#{key}>")) for key, val of extra

    @handleCustomVariables string

      ##TAG:EVENTVAR_SIMPLE: %player | the name of the player involved in the event (if any)
      .split('%player').join "<player.name>#{player?.getName()}</player.name>"

      ##TAG:EVENTVAR_SIMPLE: %pet | the name of the players pet, or placeholder text if the player doesn't have a pet
      .split('%pet').join "<player.name>#{OwnedDomainHandler.pet player}</player.name>"

      ##TAG:EVENTVAR_SIMPLE: %guildMember | a random member from the current players guild, or a random player if not in a guild
      .split('%guildMember').join "<player.name>#{OwnedDomainHandler.guildMember player}</player.name>"

      ##TAG:EVENTVAR_SIMPLE: %guild | the name of the current players guild, or a random guild if the player is not in a guild
      .split('%guild').join "<event.guildName>#{OwnedDomainHandler.guild player}</event.guildName>"

      ##TAG:EVENTVAR_SIMPLE: %hishers | the gender of the player involved in the event, in the form of "his", "hers", or "theirs"
      .split('%hishers').join getGenderPronoun gender, '%hishers'

      ##TAG:EVENTVAR_SIMPLE: %hisher | the gender of the player involved in the event, in the form of "his", "her", or "their"
      .split('%hisher').join getGenderPronoun gender, '%hisher'

      ##TAG:EVENTVAR_SIMPLE: %himher | the gender of the player involved in the event, in the form of "him", "her", or "theirs"
      .split('%himher').join getGenderPronoun gender, '%himher'

      ##TAG:EVENTVAR_SIMPLE: %she | alias for %heshe
      .split('%she').join getGenderPronoun gender, '%she'

      ##TAG:EVENTVAR_SIMPLE: %heshe | the gender of the player involved in the event, in the form of "he", "she", or "it"
      .split('%heshe').join getGenderPronoun gender, '%she'

      ##TAG:EVENTVAR_SIMPLE: %Hishers | the gender of the player involved in the event, in the form of "His", "Hers", or "Theirs"
      .split('%Hishers').join _.str.capitalize getGenderPronoun gender, '%hishers'

      ##TAG:EVENTVAR_SIMPLE: %Hisher | the gender of the player involved in the event, in the form of "His", "Her", or "Their"
      .split('%Hisher').join _.str.capitalize getGenderPronoun gender, '%hisher'

      ##TAG:EVENTVAR_SIMPLE: %Himher | the gender of the player involved in the event, in the form of "Him", "Her", or "Theirs"
      .split('%Himher').join _.str.capitalize getGenderPronoun gender, '%himher'

      ##TAG:EVENTVAR_SIMPLE: %She | alias for %Heshe
      .split('%She').join _.str.capitalize getGenderPronoun gender, '%she'

      ##TAG:EVENTVAR_SIMPLE: %Heshe | the gender of the player involved in the event, in the form of "He", "She", or "It"
      .split('%Heshe').join _.str.capitalize getGenderPronoun gender, '%she'

module.exports = exports = MessageCreator
