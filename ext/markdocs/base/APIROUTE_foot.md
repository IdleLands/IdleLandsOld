API Notes
---------
* **Every** API call will return an object that contains at least `code`, `message` and `isSuccess`. They are omitted for the sake of brevity.
* Any API call involving a player will return `pet` (if the player has a pet) and `pets` (all of their unlocked pets).
* You do not have to log in after registering.
* Conventionally, your identifier is `<your-application>#<character-name>`, but this is not enforced nor required. But if you're able, please do it.
* Any time you are sent a `player`, `guild`, or `guildInvites` object, that is the cue that you should update your client accordingly.
* The game recognizes genders "male" and "female" - all other genders are treated as "other."
* Error codes can be found [here](https://github.com/IdleLands/IdleLands/wiki/REST-Error-Codes)
* Pets can *always* have the Monster class, even if the player has not yet been that class.
* Calls to `/custom/player/submit` are throttled at a minimum of 10 seconds, but scales upwards depending on the intensity of the possible spam.
* You can determine if a player is a content moderator by checking `player.isContentModerator`.

Sample Player Object
--------------------
If you would like to see a sample player object, check [this hastebin](http://hastebin.com/fuhejacumu.dos).