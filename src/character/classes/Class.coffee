
###
  if nameless lands classes are implemented, make higher tier classes descendants of a base class
###

class Class
  load: (player) ->
    player.on 'walk', ->
      player.gainXp 1

module.exports = exports = Class