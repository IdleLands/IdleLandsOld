
_ = require "underscore"
Generator = require "./Generator"
Chance = require "chance"
Constants = require "./Constants"
chance = new Chance()

class ShopGenerator extends Generator
  constructor: (@game) ->

  generateShop: (player) ->
    shop = {}
    shop.item = @generateItem player
    shop.item = @generateItem player while shop.item.score() > player.calc.itemFindRange()*Constants.defaults.game.shopRangeBoost
    shop.price = Math.floor(shop.item.score()*(chance.floating {min: 1, max: 1 + Constants.defaults.game.shopPriceFlux, fixed: 3}))
    shop.price = 0 if shop.price < 0
    shop

  generateItem: (player) ->
    item = @game.equipmentGenerator.generateItem null, player.calc.luckBonus()

module.exports = exports = ShopGenerator
