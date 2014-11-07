
_ = require "underscore"

class Generator

  types: ['body', 'charm', 'feet', 'finger', 'hands', 'head', 'legs', 'neck', 'mainhand', 'offhand']

  mergePropInto: (baseItem, prop) ->
    if prop.type is "suffix" then baseItem.name += " of the #{prop.name}" else baseItem.name = "#{prop.name} #{baseItem.name}"
    for attr,val of prop
      continue if (not _.isNumber val) or _.isEmpty attr
      if attr of baseItem
        if _.isNumber baseItem[attr]
          baseItem[attr] += prop[attr]
        else
          if not baseItem[attr]
            console.error "bad item attribute", baseItem, attr
            console.error new Error().stack

          baseItem[attr].maximum += prop[attr]
      else
        baseItem[attr] = if _.isNaN prop[attr] then true else prop[attr]

    baseItem.name = baseItem.name.trim()

module.exports = exports = Generator