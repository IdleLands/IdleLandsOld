
_ = require "lodash"
Sandwich = require "../item/Sandwich"
Generator = require "./Generator"
Chance = require "chance"
chance = new Chance()

class SandwichGenerator extends Generator
  constructor: (@game) ->

  generateSandwich: ->
    ingredientList = @game.componentDatabase.ingredientStats
    return {name: "generic sandwich"} if not ingredientList
    baseSandwich = _.sample ingredientList['bread']

    sandwich = new Sandwich baseSandwich

    if chance.integer({min: 0, max: 2}) isnt 2
      veg = _.sample ingredientList['veg']
      @mergeIngredientInto sandwich, veg
      sandwich.name = "#{veg.name} on #{sandwich.name}"
      if chance.integer({min: 0, max: 1}) is 1
        meat = _.sample ingredientList['meat']
        @mergeIngredientInto sandwich, meat
        sandwich.name = "#{meat.name} and #{sandwich.name}"
    else
      meat = _.sample ingredientList['meat']
      @mergeIngredientInto sandwich, meat
      sandwich.name = "#{meat.name} on #{sandwich.name}"

    sandwich.name = sandwich.name.trim()
	
    @cleanUpSandwich sandwich

  cleanUpSandwich: (sandwich) ->
    (if _.isNaN val then sandwich[attr] = true) for attr,val of sandwich
    sandwich
	
  mergeIngredientInto: (sandwich, ingredient) ->
    for attr,val of ingredient
      continue if (not _.isNumber val) or _.isEmpty attr
      if attr of sandwich
        if _.isNumber sandwich[attr]
          sandwich[attr] += ingredient[attr]
        else
          sandwich[attr].maximum += ingredient[attr]
      else
        sandwich[attr] = if _.isNaN ingredient[attr] then true else ingredient[attr]

module.exports = exports = SandwichGenerator
