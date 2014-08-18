###
  all items should have a calculated item rating
  level-restricted
  <enchantment-level 1-10> <avatar> <special-attr> <retro | color | descriptor> <noun> <animal | saint | spirit>

  stats (calculated on demand):

  str: damage
  dex: to-hit
  int: magick damage
  wis: healing / buff duration,strength
  con: dodging / hp
  agi: dodging
  sentimentality: emotional damage
  piety: spiritual damage

  hidden stat: luck
###

_ = require "underscore"

class Equipment

  constructor: (options) ->
   # @name = options.name
    #@type = options.type
    #@itemClass = options.class or "basic"

    _.extend @, _.defaults options, @defaults
    console.error "ERROR in equipment constructor, name=#{@name}, type=#{@type}" if not @name or not @type

  score: ->
    ret = 0
    for attr, mult of @multipliers
      ret += @[attr]*mult if attr of @
    ret

  getName: ->
    if @enchantLevel then "+#{@enchantLevel} #{@name}" else @name

Equipment::multipliers =
  str: 1
  dex: 1
  con: 1
  int: 1
  wis: 1
  agi: 1

  ice: 1
  fire: 1
  water: 1
  earth: 1
  thunder: 1

  gold: 2
  xp: 2

  luck: 3

  strPercent: 10
  dexPercent: 10
  conPercent: 10
  intPercent: 10
  wisPercent: 10
  agiPercent: 10
  icePercent: 10
  firePercent: 10
  waterPercent: 10
  earthPercent: 10
  thunderPercent: 10

  goldPercent: 20
  xpPercent: 20

  enchantLevel: 25

  luckPercent: 30

  crit: 50
  dodge: 50
  prone: 50
  power: 50
  silver: 50
  deadeye: 50
  defense: 50
  glowing: 50

Equipment::defaults =
  itemClass: "basic"
  str: 0
  dex: 0
  int: 0
  con: 0
  wis: 0
  agi: 0
  luck: 0
  sentimentality: 0
  piety: 0
  ice: 0
  fire: 0
  water: 0
  earth: 0
  thunder: 0
  xp: 0
  gold: 0

  strPercent: 0
  dexPercent: 0
  intPercent: 0
  conPercent: 0
  wisPercent: 0
  agiPercent: 0
  luckPercent: 0
  sentimentalityPercent: 0
  pietyPercent: 0
  icePercent: 0
  firePercent: 0
  waterPercent: 0
  earthPercent: 0
  thunderPercent: 0
  xpPercent: 0
  goldPercent: 0

  enchantLevel: 0

module.exports = exports = Equipment