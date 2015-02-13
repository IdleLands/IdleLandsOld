Reduction calls are calls that are made by `Character.personalityReduce` and can be present on any `Personality`, `Class`, `Achievement`, or `Spell` and will take effect accordingly.

Note, **you should not be calling `personalityReduce` directly. Use `Character.calc.*`!**

The evaluation order is always: `player.profession`, `player.personalities` (in no specific order), `player.spellsAffectedBy`, followed by `player.achievements` - meaning classes are the highest priority and can cancel anything out if they so choose to.

Primarily this could be useful when determining item value, for example, a Mage doesn't really need Dex or Agi, but they prioritize Int. This means that they could value items only by Int (although it would be very unfair to do so!). This also means upon changing classes, values will change wildly, as will equipment. This is not necessarily a bad thing.

Reduction | Base Value | Arguments Passed | Description
--- | --- | --- | ---
[alignment](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L779) | 0 | self, baseAlignment | Called mostly by the calendar to determine alignment-specific day boosts/reductions
[ascendChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L784) | 100 | self, baseAscendChance | Called when stepping on stairs up
[beatDodge](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L606) | dex+str+agi+wis+con+int | self, baseBeatDodge | Called when attempting to prevent opponent dodging
[beatHit](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L620) | str+dex/2 | self, baseBeatHit | Called when attempting to hit opponent
[cantActMessages](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L753) | [] | self, baseCantActMessages | Called when a spell stops a players turn
[cantAct](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L748) | 0 | self, baseCantAct | Called when a spell stops a players turn
[classChangePercent](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L774) | 100 | self, potentialNewClass, baseClassChangePercent | Called every time a player meets with a trainer
[combatEndGoldGain](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L683) | 0 | self, baseCombatEndGoldGain | Called when calculating the base gold gain after combat
[combatEndXpGain](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L673) | 0 | self, baseCombatEndXpGain | Called when calculating the base xp gain after combat
[combatEndXpLoss](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L678) | maxXp/10 | self, baseCombatEndXpLoss | Called when calculating the base xp loss after combat
[combatEndXpLoss](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L688) | gold/100 | self, baseCombatEndGoldLoss | Called when calculating the base gold loss after combat
[criticalChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L661) | 1+luck+dex/2 | self, baseCriticalChance | Called when attempting to do a critical hit, before calculating damage
[damageMultiplier](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L656) | 1 | self, baseDamageMultiplier | Called when calculating damage
[damageReduction](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L651) | 0 | self, baseDamageReduction | Called when calculating damage
[damageTaken](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L743) | 0 | self, attacker, damageTotal, skillType, spellObject, reductionType | Called when any damage is taken
[damage](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L627) | str | self, baseDamage | Called when rolling any kind of damage
[descendChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L789) | 100 | self, baseDescendChance | Called when stepping on stairs down
[dodge](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L599) | agi | self, baseDodge | Called when attempting to dodge
[eventFumble](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L723) | 25 | self, baseEventFumblePercent | Called when determining if an event should fumble. Most event fumbles mean the difference between a % boost and a static number boost.
[eventModifier](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L728) | 0 | self, eventObject, baseEventModifier | Called before doing any kind of event so the probability can be adjusted
[fallChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L799) | 100 | self, baseFallChance | Called when stepping on a hole
[fleePercent](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L764) | 0.1 (0.1%) | self, baseFleePercent | Called every turn in combat before other actions
[hit](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L613) | dex+agi+con/6 | self, baseHit | Called when attempting to not get hit
[itemFindRangeMultiplier](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L700) | 1+(0.2*level/10) | self, baseItemFindRangeMultiplier | Called when a player finds or attempts to equip a new item
[itemFindRange](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L693) | (level+1)*itemFindRangeMultiplier | self, baseItemFindRange | Called when a player finds or attempts to equip a new item
[itemReplaceChancePercent](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L718) | 100 | self, baseItemReplaceChancePercent | Called when seeing if the player will swap items
[itemScore](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L705) | item.score() | self, item, baseItemScore | Called when checking the score of a new-found item
[itemSellMultiplier](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L738) | 0.05 (5%) | self, item, baseItemSellMultiplier | Called when selling an item
[luckBonus](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L758) | varies | self, baseLuckBonus
[magicalAttackTargets](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L809) | allEnemies | self, allEnemies, allCombatMembers | Called when making a magical attack to attempt to determine a better target
[minDamage](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L634) | 1 | self, baseMinDamage | Called when rolling any kind of damage
[partyLeavePercent](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L769) | 0.1 (0.1%, constant) | self, basePartyLeavePercent | Called every step on the map
[physicalAttackChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L668) | 65 | self, basePhysicalAttackChance | Called when determining whether to do a physical or magical attack at the beginning of the turn
[physicalAttackTargets](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L804) | allEnemies | self, allEnemies, allCombatMembers | Called when making a physical attack to attempt to determine a better target
[skillCrit](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L733) | 1 | self, spellObject, baseSkillCrit | Called when casting any spell to see if it should be modified
[teleportChance](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L794) | 100 | self, baseTeleportChance | Called when stepping on a non-guild teleport
[totalItemScore](https://github.com/IdleLands/IdleLands/blob/master/src/character/base/Character.coffee#L711) | all item scores | none | Called when calculating the score of a party


## Constants
Any reduction marked "constant" means that it is defined externally in the `game.json` constants file.

## Stats
Each of the following stats has both a reduction call, and a reductionPercent call (ie, `str` and `strPercent`), both accepting the arguments `self, stat` or `self, statPercent` respectively:
* str
* int
* dex
* wis
* agi
* con
* luck
* ice
* fire
* water
* earth
* thunder
* holy
* energy
* heal
* gold
* xp