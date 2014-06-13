###
  contain a map of spells that can be accessed by any class, just clone before using

  make every spell a simple function, like so:

  {
    "Poison": () ->
      cast: (caster, target) ->
      calcDamage: (target) ->
      roundTick: () ->
  }

###