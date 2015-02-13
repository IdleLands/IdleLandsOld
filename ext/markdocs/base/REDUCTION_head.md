Reduction calls are calls that are made by `Character.personalityReduce` and can be present on any `Personality`, `Class`, `Achievement`, or `Spell` and will take effect accordingly.

Note, **you should not be calling `personalityReduce` directly. Use `Character.calc.*`!**

The evaluation order is always: `player.profession`, `player.personalities` (in no specific order), `player.spellsAffectedBy`, followed by `player.achievements` - meaning classes are the highest priority and can cancel anything out if they so choose to.

Primarily this could be useful when determining item value, for example, a Mage doesn't really need Dex or Agi, but they prioritize Int. This means that they could value items only by Int (although it would be very unfair to do so!). This also means upon changing classes, values will change wildly, as will equipment. This is not necessarily a bad thing.