basedir = __dirname + "/../../../../../src/"

chai = require "chai"
mocha = require "mocha"
sinon = require "sinon"
proxyquire =  require("proxyquire").noCallThru()

expect = chai.expect
describe = mocha.describe

GameStub = require "../../../../stubs/GameStub"
RestrictedNumber = require "restricted-number"

game = GameStub.getGameStub()

describe "Tranquility", () ->
  it "Should target 4 times", () ->
    player =
    {
      name: "Oipo",
      professionName: "Archer",
      level: new RestrictedNumber(50, 9999999999, 51),
      mp: new RestrictedNumber(50, 9999999999, 51),
      special: new RestrictedNumber(50, 9999999999, 51),
      party: {currentBattle:{turnOrder: [{hp: new RestrictedNumber(50, 9999999999, 51), fled: no, party: {}, id: 1}], emitEvents: ->}}
      getGender: -> "Male"
      getName: -> "Oipo"
      many: (event, n, func) ->
        for i in [0..n] by 1
          func()
      off: ->
    }
    newSpell = proxyquire(basedir + 'character/base/Spell', { "../../system/handlers/MessageCreator": class MessageCreator
      @doStringReplace: (one, two, three) ->
    }, '@noCallThru': true )
    newMultishot = proxyquire(basedir + 'character/spells/combat-skills/archer/Multishot', { "../../../base/Spell": newSpell
    }, '@noCallThru': true)
    spell = new newMultishot game, player
    expect(spell.spellPower).to.equal(3)
    ret = spell.determineTargets()
    expect(ret.length).to.equal(4)
    expect(ret[0].id).to.equal(1)