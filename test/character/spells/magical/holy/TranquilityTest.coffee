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
  it "Should have a specific duration", () ->
    player =
    {
      name: "Oipo",
      professionName: "Cleric",
      level: new RestrictedNumber(50, 9999999999, 0),
      mp: new RestrictedNumber(50, 9999999999, 0),
      party: {currentBattle:{turnOrder: [], emitEvents: ->}}
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
    newTranquility = proxyquire(basedir + 'character/spells/magical/holy/Tranquility', { "../../../base/Spell": newSpell
    }, '@noCallThru': true)
    spell = new newTranquility game, player
    expect(spell.spellPower).to.equal(1)
    expect(spell.calcDuration()).to.equal(2)
    expect(spell.name).to.equal("tranquility")

    spell.affect [player]
    expect(spell.turns[player.name]).to.equal(0)