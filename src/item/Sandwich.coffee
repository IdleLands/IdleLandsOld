_ = require "underscore"

class Sandwich

  constructor: (options) ->
    _.extend @, _.defaults options, Sandwich.defaults
    #console.error "ERROR in sandwich constructor, name=#{@name}" if not @name

  getName: -> @name

  @defaults =
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

    crit: 0
    dodge: 0
    prone: 0
    power: 0
    silver: 0
    deadeye: 0
    defense: 0
    glowing: 0

module.exports = exports = Sandwich
