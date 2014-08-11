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
    @name = options.name
    @type = options.type
    @itemClass = options.class or "basic"
    console.error "ERROR in equipment constructor, name=#{@name}, type=#{@type}" if not @name or not @type

    @str = options.str or 0
    @dex = options.dex or 0
    @int = options.int or 0
    @con = options.con or 0
    @wis = options.wis or 0
    @agi = options.agi or 0

    @strPercent = options.strPercent or 0
    @dexPercent = options.dexPercent or 0
    @intPercent = options.intPercent or 0
    @conPercent = options.conPercent or 0
    @wisPercent = options.wisPercent or 0
    @agiPercent = options.agiPercent or 0

    @luck = options.luck or 0
    @sentimentality = options.sentimentality or 0
    @piety = options.piety or 0

    @luckPercent = options.luckPercent or 0
    @sentimentalityPercent = options.sentimentalityPercent or 0
    @pietyPercent = options.pietyPercent or 0

    @ice = options.ice or 0
    @fire = options.fire or 0
    @water = options.water or 0
    @earth = options.earth or 0
    @thunder = options.thunder or 0

    @icePercent = options.icePercent or 0
    @firePercent = options.firePercent or 0
    @waterPercent = options.waterPercent or 0
    @earthPercent = options.earthPercent or 0
    @thunderPercent = options.thunderPercent or 0

    @enchantLevel = options.enchantLevel or 0

    _.each ['silver','power','deadeye','prone','offense','defense','crit','dodge','glowing'], (prop) =>
      @[prop] = true if prop of options

  # TODO
  #score xp, xpP, gold, goldP
  # also, special props ^^^
  score: ->
    @str + @dex + @con + @int + @wis + @agi +
    (@luck*3) +
    @ice + @fire + @water + @earth + @thunder +
    @icePercent*10 + @firePercent*10 + @waterPercent*10 + @earthPercent*10 + @thunderPercent*10

  getName: ->
    if @enchantLevel then "+#{@enchantLevel} #{@name}" else @name

module.exports = exports = Equipment