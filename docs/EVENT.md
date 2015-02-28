Events are the driving force behind IdleLands. They can happen in or outside of combat. These can be bound to by a `Class`, `Personality`, or a `Spell`, but take note that any spell effects binding to a duration are removed when battle is exited, and any events bound to by a personality should be removed as well.

The domain below implies the first part of the event. For example, in the Player domain, the `party.join` event should be watched for as `player.party.join`.

Any event in the `combat` domain can optionally take on some other forms `self`, `ally`, or `enemy`. Some events are emitted to all players, and the side will be determined automatically, ie, `combat.self.turn.end`. Self is emitted to the target of the action, ally is emitted to the party members of self, and enemy is emitted to everyone else. Events that follow this format will be denoted `[sea]`.

Player Emit | Arguments Passed | Description
--- | --- | ---
[gold.gain](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L828) | player, goldGained | Emitted when a player gains gold
[gold.guildDonation](https://github.com/IdleLands/IdleLands/blob/master/src/system/managers/GuildManager.coffee#L338) | guild.name, gold | Emitted when a player willingly donates gold to their guild
[gold.guildTax](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Guild.coffee#L138) | guildName, goldTaxed | Emitted when a guild collects tax from a member
[gold.lose](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L838) | player, goldLost | Emitted when a player loses gold
[level.down](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/LevelDownEvent.coffee#L26) | player, currentLevel, newLevel | Emitted when a player loses a level
[level.up](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L873) | player | Emitted when a player levels up
[profession.change](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L539) | player, oldClass, newClass | Emitted when a player changes class
[sellItem](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/EventHandler.coffee#L227) | player, item, value | Emitted when a player sells an item
[shop.buy](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L591) | player, item, itemCost | Emitted when a player buys an item from the shop manually
[shop.pet](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L647) | player, pet | Emitted when a player buys a pet
[shop.pet](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L668) | player, pet, cost | Emitted when a player upgrades a pet
[trainer.ignore](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L249) | player, newClass | Emitted when a player talks to a trainer but didn't change classes
[trainer.isAlready](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L238) | player, newClass | Emitted when a player talks to a trainer but is already a class
[trainer.speak](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L253) | player, newClass | Emitted when a player talks to a trainer and changed classes
[xp.gain](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L849) | player, xpGained | Emitted when a player gains xp
[xp.lose](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L852) | player, xpLost | Emitted when a player loses xp


Event Emit | Arguments Passed | Description
--- | --- | ---
[blessGoldParty](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/GoldPartyEvent.coffee#L43) | player, {gold, realGold} | Emitted when a player gets free money while in a party
[blessGold](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/GoldEvent.coffee#L36) | player, {gold, realGold} | Emitted when a player gets free money
[blessItem](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/ItemModEvent.coffee#L47) | player, item, boost | Emitted when a player gets a blessing on an item
[blessXpParty](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/XpPartyEvent.coffee#L42) | player, {xp, realXp, percentXp} | Emitted when a player gets some free xp while in a party
[blessXp](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/XpEvent.coffee#L41) | player, {xp, realXp, percentXp} | Emitted when a player gets some free xp
[bossbattle.loot](https://github.com/IdleLands/IdleLands/blob/master/src/event/BossFactory.coffee#L68) | member, itemName, item | Emitted when a party member loots a boss item
[bossbattle.lootcollectible](https://github.com/IdleLands/IdleLands/blob/master/src/event/BossFactory.coffee#L82) | member, bossBaseName, item | Emitted when a party member loots a boss collectible
[bossbattle.lose](https://github.com/IdleLands/IdleLands/blob/master/src/event/BossFactory.coffee#L96) | member, bossBaseName | Emitted when a party member loses a boss battle
[bossbattle.win](https://github.com/IdleLands/IdleLands/blob/master/src/event/BossFactory.coffee#L85) | member, bossBaseName | Emitted when a party member wins a boss battle
[cataclysm.blackrays](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/BlackRays.coffee#L15) | cataclysm | Emitted when a player is affected by the blackrays cataclysm
[cataclysm.fatehand](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/Fatehand.coffee#L15) | cataclysm | Emitted when a player is affected by the fatehand cataclysm
[cataclysm.hatredwave](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/HatredWave.coffee#L15) | cataclysm | Emitted when a player is affected by the hatredwave cataclysm
[cataclysm.hoperays](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/HopeRays.coffee#L15) | cataclysm | Emitted when a player is affected by the hoperays cataclysm
[cataclysm.skybrightshine](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/SkyShinesBright.coffee#L15) | cataclysm | Emitted when a player is affected by the skybrightshine cataclysm
[cataclysm.skyscornglow](https://github.com/IdleLands/IdleLands/blob/master/src/event/cataclysms/SkyGlowsScornfully.coffee#L15) | cataclysm | Emitted when a player is affected by the skyscornglow cataclysm
[cataclysm](https://github.com/IdleLands/IdleLands/blob/master/src/event/Cataclysm.coffee#L28) | cataclysm | Emitted when a player is affected by a cataclysm
[enchant](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/EnchantEvent.coffee#L109) | player, item, newEnchantLevel | Emitted when a player has an enchant event happen
[findItem](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/EventHandler.coffee#L211) | player, item | Emitted when a player finds an item on the ground
[flipStat](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/FlipStatEvent.coffee#L32) | player, item, stat, val | Emitted when a player has a switcheroo happen
[forsakeGoldParty](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/GoldPartyEvent.coffee#L44) | player, {gold, realGold} | Emitted when a player gets loses money while in a party
[forsakeGold](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/GoldEvent.coffee#L37) | player, {gold, realGold} | Emitted when a player gets loses money
[forsakeItem](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/ItemModEvent.coffee#L48) | player, item, boost | Emitted when a player gets an anti-blessing on an item
[forsakeXpParty](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/XpPartyEvent.coffee#L43) | player, {xp, realXp, percentXp} | Emitted when a player loses xp while in a party
[forsakeXp](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/XpEvent.coffee#L42) | player, {xp, realXp, percentXp} | Emitted when a player loses xp
[levelDown](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/LevelDownEvent.coffee#L23) | player, currentLevel, newLevel | Emitted when a player loses a level
[merchant](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/MerchantEvent.coffee#L43) | player, {item, gold, shopGold} | Emitted when a player buys an item from a shop
[monsterbattle](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/MonsterBattleEvent.coffee#L22) | player | Emitted when a player gets causes a battle with monsters
[party.join](https://github.com/IdleLands/IdleLands/blob/master/src/event/Party.coffee#L63) | none | Emitted when a player joins a party
[party.leave](https://github.com/IdleLands/IdleLands/blob/master/src/event/Party.coffee#L72) | none | Emitted when a player leaves a party
[providence](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/ProvidenceEvent.coffee#L174) | player | Emitted when a player gets really unlucky
[tinker](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/EnchantEvent.coffee#L108) | player, item, newEnchantLevel | Emitted when a player has a tinker event happen
[towncrier](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/TownCrierEvent.coffee#L21) | player | Emitted when a player gets their ears attacked by the nearest town crier
[treasurechest.find](https://github.com/IdleLands/IdleLands/blob/master/src/event/TreasureFactory.coffee#L28) | player, chestName | Emitted when a player finds a treasure chest
[treasurechest.loot](https://github.com/IdleLands/IdleLands/blob/master/src/event/TreasureFactory.coffee#L25) | player, chestName, item | Emitted when a player loots an item from a treasure chest


Explore Emit | Arguments Passed | Description
--- | --- | ---
[hit.wall](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L490) | player | Emitted when a player hits a wall
[transfer.ascend](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L326) | player, newMap | Emitted when a player changes maps via ascending
[transfer.descend](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L327) | player, newMap | Emitted when a player changes maps via descending
[transfer.fall](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L325) | player, newMap | Emitted when a player changes maps via falling
[transfer.guildTeleport](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L361) | player, newMap | Emitted when a player goes to their guild hall
[transfer.manualWarp](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L113) | player, newMap | Emitted when a player warps somewhere manually
[transfer.teleport](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L328) | player, newMap | Emitted when a player changes maps via teleporting
[transfer](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L322) | player, newMap | Emitted when a player changes maps
[walk.carpet](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L503) | player | Emitted when a player takes a step on carpet
[walk.dirt](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L501) | player | Emitted when a player takes a step on dirt
[walk.grass](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L499) | player | Emitted when a player takes a step on grass
[walk.gravel](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L502) | player | Emitted when a player takes a step on gravel
[walk.ice](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L507) | player | Emitted when a player takes a step on ice
[walk.lava](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L508) | player | Emitted when a player takes a step on lava
[walk.sand](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L504) | player | Emitted when a player takes a step on sand
[walk.snow](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L505) | player | Emitted when a player takes a step on snow
[walk.swamp](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L506) | player | Emitted when a player takes a step on swamp
[walk.tile](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L509) | player | Emitted when a player takes a step on tile
[walk.void](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L511) | player | Emitted when a player takes a step on the void (aka, off the map)
[walk.water](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L500) | player | Emitted when a player takes a step on water
[walk.wood](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L510) | player | Emitted when a player takes a step on wood
[walk](https://github.com/IdleLands/IdleLands/blob/master/src/character/player/Player.coffee#L496) | player | Emitted when a player takes a step


Combat Emit | Arguments Passed | Description
--- | --- | ---
[[sea].critical](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L341) | attacker, attacked | Emitted when a player (`attacker`) scores a critical hit on `attacked`
[[sea].criticalled](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L342) | attacker, attacked | Emitted when a player (`attacked`) is hit by a critical hit
[[sea].damage](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L592) | attacker, defender, {type, damage} | Emitted when a player (`attacker`) damages `defender` (hp)
[[sea].damaged](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L593) | attacker, defender, {type, damage} | Emitted when a player (`defender`) is damaged (hp)
[[sea].deflect](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L288) | attacked, attacker | Emitted when a player (`attacked`) deflects an attack
[[sea].deflected](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L289) | attacked, attacker | Emitted when a player (`attacker`) is deflected
[[sea].dodge](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L261) | attacked, attacker | Emitted when a player (`attacked`) dodges an attack
[[sea].dodged](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L262) | attacked, attacker | Emitted when a player (`attacker`) is dodged
[[sea].effect.poison](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L377) | attacker, attacked | Emitted when a player (`attacker`) poisons `attacked`
[[sea].effect.poisoned](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L378) | attacker, attacked | Emitted when a player (`attacked`) is poisoned
[[sea].effect.prone](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L369) | attacker, attacked | Emitted when a player (`attacker`) prones `attacked`
[[sea].effect.proned](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L370) | attacker, attacked | Emitted when a player (`attacked`) is knocked prone
[[sea].effect.shatter](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L373) | attacker, attacked | Emitted when a player (`attacker`) shatters `attacked`s defenses
[[sea].effect.shattered](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L374) | attacker, attacked | Emitted when a player (`attacked`) has defenses shattered
[[sea].effect.sturdy](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L598) | player | Emitted when a player triggers sturdy
[[sea].effect.vampire](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L385) | attacker, attacked | Emitted when a player (`attacker`) vampires `attacked`
[[sea].effect.vampired](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L386) | attacker, attacked | Emitted when a player (`attacked`) is vampired
[[sea].effect.venom](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L381) | attacker, attacked | Emitted when a player (`attacker`) venoms `attacked`
[[sea].effect.venomed](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L382) | attacker, attacked | Emitted when a player (`attacked`) is venomed
[[sea].energize](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L615) | attacker, defender, {type, damage} | Emitted when a player (`attacker`) healed `defender` (mp)
[[sea].energized](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L616) | attacker, defender, {type, damage} | Emitted when a player (`defender`) is healed (mp)
[[sea].flee](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L221) | player | Emitted when a player flees combat
[[sea].heal](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L587) | attacker, defender, {type, damage} | Emitted when a player (`attacker`) heals `defender` (hp)
[[sea].healed](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L588) | attacker, defender, {type, damage} | Emitted when a player (`defender`) is healed (hp)
[[sea].kill](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L345) | attacker, attacked, {dead} | Emitted when a player (`attacker`) scores a lethal blow on `attacked`
[[sea].killed](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L346) | attacker, attacked, {dead} | Emitted when a player (`attacked`) is killed
[[sea].miss](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L276) | attacker, attacked | Emitted when a player (`attacker`) misses an attack
[[sea].missed](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L277) | attacker, attacked | Emitted when a player (`attacked`) is missed
[[sea].skill.duration.beginAt](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L217) | caster, player, {skill, turns} | Emitted by the recipient of the over-time skill
[[sea].skill.duration.begin](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L216) | caster, player, {skill, turns} | Emitted by the caster of the over-time skill
[[sea].skill.duration.endAt](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L250) | caster, player | Emitted by the recipient of the ended skill
[[sea].skill.duration.end](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L249) | caster, player | Emitted by the caster of the ended skill
[[sea].skill.duration.refresh](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L207) | caster, player, {skill, turns} | Emitted by the caster of the refreshed skill
[[sea].skill.duration.refreshed](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L208) | caster, player, {skill, turns} | Emitted by the recipient of the refreshed skill
[[sea].skill.magical.use](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L192) | caster, player, {skill} | Emitted by the caster of the skill (if the skill is magical)
[[sea].skill.magical.used](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L193) | caster, player, {skill} | Emitted by the recipient of the skill used (if the skill is magical)
[[sea].skill.physical.use](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L190) | caster, player, {skill} | Emitted by the caster of the skill (if the skill is physical)
[[sea].skill.physical.used](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L191) | caster, player, {skill} | Emitted by the recipient of the skill used (if the skill is physical)
[[sea].skill.use](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L186) | caster, player, {skill} | Emitted by the caster of the skill
[[sea].skill.used](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Spell.coffee#L187) | caster, player, {skill} | Emitted by the recipient of the skill used
[[sea].startled](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L207) | player | Emitted when a player gets startled
[[sea].target](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L332) | attacker, attacked | Emitted when a player (`attacker`) targets `attacked`
[[sea].target](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L337) | attacker, attacked | Emitted when a player (`attacker`) attacks `attacked`
[[sea].targeted](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L333) | attacker, attacked | Emitted when a player (`attacked`) is targetted
[[sea].targeted](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L338) | attacker, attacked | Emitted when a player (`attacked`) is attacked
[[sea].turn.end](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L179) | player | Emitted when a player ends a turn
[[sea].turn.start](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L175) | player | Emitted when a player takes a turn
[[sea].vitiate](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L620) | attacker, defender, {type, damage} | Emitted when a player (`attacker`) attacked `defender` (mp)
[[sea].vitiated](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L621) | attacker, defender, {type, damage} | Emitted when a player (`defender`) is attacked (mp)
[battle.end](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L407) | turnorder | Emitted when a battle ends properly
[battle.stale](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L401) | turnorder | Emitted when a battle goes stale
[battle.start](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L156) | turnorder | Emitted when the battle starts
[effect.darkside](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L642) | attacker, darksideDamage | Emitted when an attacker deals darkside damage to itself
[effect.punish.damage](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L634) | attacker, defender, {damage} | Emitted when a defender hits an attacker with punish damage
[effect.punished.damage](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L635) | attacker, defender, {damage} | Emitted when an attacker is punished by a defender
[party.lose](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L425) | losers, winners | Emitted when a party loses combat
[party.win](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L428) | winners, losers | Emitted when a party wins combat
[round.end](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L187) | turnorder | Emitted when the round is over
[round.start](https://github.com/IdleLands/IdleLands/blob/master/src/event/Battle.coffee#L169) | turnorder | Emitted when a new round starts


