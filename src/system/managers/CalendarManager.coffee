
requireDir = require "require-dir"
timePeriods = requireDir "../../event/calendar", recurse: yes

_ = require "lodash"

class CalendarManager

  constructor: (@game) ->
    @date = [0, 0, 0]
    @yearOrder = ['Aether', 'Hades', 'Demeter', 'Serpentis', 'Uranus']
    @monthOrder = ['Hephaestus', 'Boreas', 'Crono', 'Poseidon', 'Hermes', 'Gaia', 'Zeus']
    @dayOrder = ['Str', 'Earth', 'Humanity', 'Evil', 'Charisma',
                 'Good', 'Int', 'Monster', 'Luck', 'Dex',
                 'Agi', 'Calamity', 'Wis', 'Con', 'Monster']

  advance: (days) ->
    days = days % 525
    if days < 0
      days = 525 + days
    @date[2] += days
    @date = @cleanDate @date

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

CalendarManager::allTimePeriods = -> timePeriods

CalendarManager::getDateEffects = ->
  [ timePeriods.year["#{@yearOrder[@date[0]]}Year"],
    timePeriods.month["#{@monthOrder[@date[1]]}Month"],
    timePeriods.day["#{@dayOrder[@date[2]]}Day"]
  ]

CalendarManager::getDateName = ->
  date = @getDateEffects()
  "#{date[0].dateName}, #{date[1].dateName}, #{date[2].dateName}"

module.exports = exports = CalendarManager
