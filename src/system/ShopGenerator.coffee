
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
    shop.price = Math.floor(shop.item.score()*
                (chance.floating {min: 1, max: 1 + Constants.defaults.game.shopPriceFlux, fixed: 3})*
                (1 + player.calc.stat('shopPercent')/100))
    shop.price = 1 if shop.price <= 0
    shop.price *= 7 # gouge the players for gold, muhahaha
    shop

  regionShop: (player) ->
    shop = {}
    shop.slots = []
    region = player.getRegion()
    shop.region = region.name
    for i in [0...region.shopSlots()]
      item = @generateItem player
      item = @generateItem player while item.score() > player.calc.itemFindRange()*Constants.defaults.game.shopRangeBoost*region.shopQuality()
      price = Math.floor(item.score()*region.shopMult()*
                (chance.floating {min: 1, max: 1 + Constants.defaults.game.shopPriceFlux, fixed: 3})*
                (1 + player.calc.stat('shopPercent')/100))
      price = 1 if price <= 0
      price *= 7 # gouge the players for gold, muhahaha
      shop.slots[i] = {item: item, price: price}
    shop

  generateItem: (player) ->
    item = @game.equipmentGenerator.generateItem null, player.calc.luckBonus()

module.exports = exports = ShopGenerator
