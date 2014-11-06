
requireDir = require "require-dir"
timePeriods = requireDir "../character/calendar", recurse: yes
#month = requireDir "../character/calendar/month"
#day = requireDir "../character/calendar/day"

_ = require "underscore"

class Calendar

  constructor: (@game) ->
    @date = [0, 0, 0]
    @yearOrder = ['Aether', 'Hades', 'Demeter', 'Serpentis', 'Uranus']
    @monthOrder = ['Hephaestus', 'Boreas', 'Crono', 'Poseidon', 'Hermes', 'Gaia', 'Zeus']
    @dayOrder = ['Str', 'Earth', 'Humanity', 'Evil', 'Monster',
                 'Good', 'Int', 'Luck', 'Dex', 'Monster',
                 'Agi', 'Calamity', 'Wis', 'Con', 'Monster']

  advance: (days) ->
    days = days % 525
    if days < 0
      days = 525 + days
    @date[2] += days
    @date = @cleanDate @date
    @dateEffects = getDateEffects()

  cleanDate: (date) ->
    if date[2] > 14
      date[2] -= 15
      date[1]++
      @cleanDate date
    else if date[1] > 6
      date[1] -= 7
      date[0]++
      @cleanDate date
    else if date[0] > 4
      date[0] -= 5
      @cleanDate date
    date

Calendar::allTimePeriods = -> timePeriods

Calendar::getDateEffects = ->
  [ timePeriods.year["#{@yearOrder[@date[0]]}Year"],
    timePeriods.month["#{@monthOrder[@date[1]]}Month"],
    timePeriods.day["#{@dayOrder[@date[2]]}Day"]
  ]

module.exports = exports = Calendar
