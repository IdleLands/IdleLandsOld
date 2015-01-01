
_ = require "lodash"
_.str = require "underscore.string"
API = require "./API"

chance = new (require "chance")()

getCD = -> API.gameInstance.componentDatabase

class RandomDomainHandler

  placeholder = @placeholder = ->
    _.sample [
      'a red potato'
      'a glass shark'
      'a shiny mackerel'
      'a paper goatee'
      'a bearded hat'
      'a wooden plank'
    ]

  @pet = ->
    (_.sample API.gameInstance.petManager.pets)?.name or placeholder()

  @activePet = ->
    petHash = API.gameInstance.petManager.activePets
    petHash[_.sample _.keys petHash]?.name or placeholder()

  @player = ->
    (_.sample API.gameInstance.playerManager.players).name

  @deity = ->
    _.sample [
      'Kirierath, The Goddess of Riches'
      'Ishkalorht, The God of Rampage and Brawling'
      'Shashkajze, The God of Items'
      'Ulrya, The Goddess of Time'
    ]

  @guild = ->
    (_.sample API.gameInstance.guildManager.guilds)?.name or placeholder()

  @map = ->
    _.sample _.keys API.gameInstance.world.maps

  @item = (args) ->
    type = args?.type or (_.sample _.keys getCD().itemStats)
    (_.sample getCD().itemStats[type])?.name or placeholder() #should only happen locally

  @monster = ->
    (_.sample getCD().monsters)?.name or placeholder() #should only happen locally

  @ingredient = (args) ->
    type = args?.type or (_.sample _.keys getCD().ingredientStats)
    (_.sample getCD().ingredientStats[type])?.name or placeholder() # should only happen locally

  #@party = -> (use @placeholder when @party size lookup fails)

class CustomHandler
  @dict = (props) ->
    {funct} = props[0]
    realFunct = funct.toLowerCase()

    if realFunct is "nouns"
      realFunct = "noun"
      isPlural = yes

    value = _.sample getCD().generatorCache[realFunct]
    value = if funct.toLowerCase() is funct then value.toLowerCase() else _.str.capitalize value

    value = value.substring 0, value.length-1 if realFunct is "noun" and not isPlural #all nouns end in 's'

    value

  @chance = (props) ->
    {funct, args} = props[0]
    chance[funct]? args

  @random = (props) ->
    {funct, args} = props[0]
    RandomDomainHandler[funct]? args, props

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

    #\$([a-zA-Z\:#0-9 {},']+)\$

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

    getVarProps = (keyString) ->
      terms = keyString.split " "
      varProps = []
      _.each terms, (term) ->
        [props, cacheNum] = term.split "#"
        [domain, funct] = props.split ":", 2
        args = (_.str.trim props.substring 1+funct.length+props.indexOf funct).split("'").join '"'

        varProps.push
          domain: domain
          funct: funct
          args: if args then JSON.parse args
          cacheNum: parseInt cacheNum

      varProps

    transformVarProps = (props) ->
      {domain, funct, cacheNum} = props[0]

      return varCache[domain][funct][cacheNum] if (_.isNumber cacheNum) and varCache[domain]?[funct]?[cacheNum]

      retVal = CustomHandler[domain]? props

      if not _.isNaN cacheNum
        varCache[domain] = {} if not varCache[domain]
        varCache[domain][funct] = [] if not varCache[domain][funct]
        varCache[domain][funct][cacheNum] = retVal

      retVal

    testString = "$dict:adjective#1$ $dict:adjective#1$ $dict:noun$ $dict:Noun$ $dict:Nouns$ $dict:nouns$ $random:pet$ $random:player$ $random:deity$ $random:guild$ $random:map$ $random:item$ $random:monster$ $random:item:{'type':'body'}$ $random:ingredient$ $random:placeholder$ $chance:age$"
    #testString = "$random:player$ ($random:party#1 party:member#1$) goes down the $dict:adjective#1$ $dict:noun$ and finds a $dict:adjective#1$ $dict:Noun$ named $chance:name:{'middle':true}$. A local townsperson named $chance:name:{'female':true}#1$, with a twin sister also named $chance:name#1$ said it was $dict:adjective$!"
    t2 = testString.replace /\$([a-zA-Z\:#0-9 {},']+)\$/g, (match, p1, p2) ->
      transformVarProps getVarProps p1

    console.log testString
    console.log t2

    string

  @doStringReplace: (string, player = {}, extra = {}) ->
    gender = player?.getGender()
    string = _.str.clean string

    (string = string.split("%#{key}").join (if key is "item" then val else "<event.#{key}>#{val}</event.#{key}>")) for key, val of extra

    @handleCustomVariables string
      .split('%player').join "<player.name>#{player.name}</player.name>"
      .split('%hishers').join getGenderPronoun gender, '%hishers'
      .split('%hisher').join getGenderPronoun gender, '%hisher'
      .split('%himher').join getGenderPronoun gender, '%himher'
      .split('%she').join getGenderPronoun gender, '%she'
      .split('%heshe').join getGenderPronoun gender, '%she'

      .split('%Hishers').join _.str.capitalize getGenderPronoun gender, '%hishers'
      .split('%Hisher').join _.str.capitalize getGenderPronoun gender, '%hisher'
      .split('%Himher').join _.str.capitalize getGenderPronoun gender, '%himher'
      .split('%She').join _.str.capitalize getGenderPronoun gender, '%she'
      .split('%Heshe').join _.str.capitalize getGenderPronoun gender, '%she'

module.exports = exports = MessageCreator
