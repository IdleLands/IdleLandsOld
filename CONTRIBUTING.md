## Events
* No overtly offensive jokes (ie, sexism, rape, etc)
* No weird unicode (ie, RTL, LTR changing) at this time - lets keep it interpretable by every client

## Code
* Follow the existing code style.
* When working on one issue, move your existing code into a new branch and work out of that branch. I will not accept numerous PRs regarding one issue.
* Please test your code. I can't test everything myself.
* When implementing gameplay changes, new classes, spells, etc, please at least leave the game run in your console for an hour just to make sure all is working correctly.
* If your code does not pass Travis-CI, it won't be merged.
* If you have something that players should be using, please take a shot at implementing the IRC commands for it, as well as REST API routes.

## Maps
* Make sure you have "snap to grid set" so any time you add an "interactable" it can be found by the game.
* Show me a screenshot of the map, either via PM or in your pull request.

## Bosses
* Make sure you have "snap to grid set" so it can be found by the game.
* Show me a screenshot of where your boss is.

### Things to Update When Working With Code
* Documentation
* If you've added an achievement, you're good to go after you document it.
* If you've added a spell, you're good to go after you document it.
* Documentation
* If you've added or updated a personality, you're good to go after you document it. If you've created personality which increases fleePercent - please update [src/character/classes/Jester.coffee](https://github.com/IdleLands/IdleLands/blob/master/src/character/classes/Jester.coffee).
* If you've added a class, please add some [monsters](https://github.com/IdleLands/IdleLands/blob/master/assets/data/monsters/monster.txt#L202) to reflect the new class and consider updating isPhysical/isMagical/isMedic/isDPS/isTank/isSupport functions in [the game constants](https://github.com/IdleLands/IdleLands/blob/master/src/system/utilities/Constants.coffee). Feel free to get creative when describing the orcish, kobold, etc versions of your class.
* Please make sure your stuff is documented.
* If you're working with the API, please [update the REST API wiki page](https://github.com/IdleLands/IdleLands/wiki/REST-API) and the [error code wiki page](https://github.com/IdleLands/IdleLands/wiki/REST-Error-Codes).
