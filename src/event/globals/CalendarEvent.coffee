
_ = require "lodash"

GlobalEvent = require "../GlobalEvent"

`/**
 * This event moves the calendar forward.
 *
 * @name Calendar
 * @category Player
 * @package Global Events
 * @happensEvery 10 minutes
 */`
class CalendarEvent extends GlobalEvent
  go: ->
    @game.calendar.advance 1
    @game.broadcast ">>> CALENDAR: It is now the #{@game.calendar.getDateName()}."

module.exports = exports = CalendarEvent