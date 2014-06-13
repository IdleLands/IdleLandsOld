
ko = require "knockout"
RestrictedNumber = require "../RestrictedNumber"

class CharacterType

###
  YesMan
  NoSir
  SadSandman
  PokeyPriest
  Random
  Magical
  Physical
###

class Character

  @level      = 0

  @health     = ko.computed () =>
  @mana       = ko.computed () =>
  @speed      = ko.computed () =>
  @magic      = ko.computed () =>
  @power      = ko.computed () =>
  @luck       = ko.computed () =>
  @consti     = ko.computed () =>

  @emotional  = ko.computed () =>
  @spiritual  = ko.computed () =>
  @physical   = ko.computed () =>
  @magical    = ko.computed () =>

exports.Character = Character