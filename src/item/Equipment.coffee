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

class Equipment

  constructor: (options) ->
    @name = options.name

    @str = options.str
    @dex = options.dex
    @int = options.int
    @con = options.con
    @wis = options.wis
    @agi = options.agi

    @luck = options.luck
    @sentimentality = options.sentimentality
    @piety = options.piety

    @ice = options.ice
    @fire = options.fire
    @water = options.water
    @earth = options.earth
    @thunder = options.thunder

    @icePercent = options.icePercent
    @firePercent = options.firePercent
    @waterPercent = options.waterPercent
    @earthPercent = options.earthPercent
    @thunderPercent = options.thunderPercent

  score: () ->

module.exports = exports = Equipment