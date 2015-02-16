IdleLands provides a REST API for developers to create external clients to interface with the game. Developers will have to make note of a few things, namely: you have to tell the game when you're taking your turn, and you will have a token that is generated every time you login, that you must use or subsequent requests will be denied. This is to avoid sending an identifier and password for every request.

Please note, the game does include a "heartbeat" mechanism, and if you do not send your next turn within 30 seconds, the game will log you out. External clients should include automatic login mechanisms for these situations, so players do not have to log back in manually.

There are also some API limits:
* You cannot have more than one turn in a 10-second span
* You cannot request more than one map in a 10-second span
* You cannot create more than one character every 24 hours

These limits only apply to each individual user of the client, not the client as a whole, so you can definitely have concurrent users for your client.

The base API url is http://api.idle.land (https also available) -- feel free to use this for testing! Just don't make too many characters, please.

Verb | Route | Request Data | Return Data
--- | --- | --- | ---
PATCH | [/custom/mod/approve](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L26) | {identifier} | {}
POST | [/custom/mod/list](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L20) | {identifier} | {customs}
PATCH | [/custom/mod/reject](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L32) | {identifier} | {}
PUT | [/custom/player/submit](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L8) | {identifier, data
POST | [/custom/redeem](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L14) | {identifier, crierId, giftId} | {}
POST | [/game/battle](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Battle.coffee#L11) | {battleId} | {battle}
POST | [/game/map](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Map.coffee#L8) | {map} | {map}
PUT | [/guild/building/construct](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L88) | {identifier, building, slot, token} | {player}
PATCH | [/guild/building/setProperty](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L100) | {identifier, building, property, value} | {guild}
POST | [/guild/building/upgrade](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L94) | {identifier, building, token} | {player}
PUT | [/guild/create](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L10) | {identifier, guildName, token} | {guild}
POST | [/guild/invite/manage](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L36) | {identifier, accepted, token} | {guild}
PUT | [/guild/invite/player](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L30) | {identifier, invName, token} | {guild}
POST | [/guild/leave](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L16) | {identifier, token} | {guild}
PUT | [/guild/leave](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L22) | {identifier, token} | {guild}
POST | [/guild/manage/buff](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L68) | {identifier, type, tier, token} | {guild}
POST | [/guild/manage/demote](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L50) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/donate](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L62) | {identifier, gold, token} | {}
POST | [/guild/manage/kick](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L56) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/promote](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L44) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/tax](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L74) | {identifier, taxPercent, token} | {guild}
PUT | [/guild/move](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L106) | {identifier, newLoc, token} | {player}
GET | [/img/tiles.png](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/REST.coffee#L38) | {} | IdleLands Tileset
PUT | [/pet/buy](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L10) | {identifier, type, name, attrs, token} | {}
PATCH | [/pet/class](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L46) | {identifier, petClass, token} | {}
PUT | [/pet/feed](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L22) | {identifier, token} | {}
PUT | [/pet/inventory/equip](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L70) | {identifier, itemSlot, token} | {}
PUT | [/pet/inventory/give](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L52) | {identifier, itemSlot, token} | {}
PATCH | [/pet/inventory/sell](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L64) | {identifier, itemSlot, token} | {}
POST | [/pet/inventory/take](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L58) | {identifier, itemSlot, token} | {}
POST | [/pet/inventory/unequip](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L76) | {identifier, itemUid, token} | {}
PUT | [/pet/smart](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L34) | {identifier, option, value, token} | {}
PATCH | [/pet/swap](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L40) | {identifier, petId, token} | {}
POST | [/pet/takeGold](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L28) | {identifier, token} | {}
POST | [/pet/upgrade](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L16) | {identifier, stat, token} | {}
POST | [/player/action/teleport](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/PlayerActions.coffee#L8) | {identifier, newLoc, token} | {}
POST | [/player/action/turn](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/TurnAction.coffee#L9) | {identifier, token} | {player, pet}
POST | [/player/auth/login](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L34) | {identifier, password} | {player, token}
POST | [/player/auth/logout](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L27) | {identifier, token} | {}
POST | [/player/auth/password](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L41) | {identifier, password, token} | {}
PUT | [/player/auth/register](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L19) | {identifier, name, password} | {player, token}
PUT | [/player/manage/gender/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGender.coffee#L8) | {identifier, gender, token} | {}
PUT | [/player/manage/inventory/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L9) | {identifier, itemSlot, token} | {player}
POST | [/player/manage/inventory/sell](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L15) | {identifier, invSlot, token} | {player}
PATCH | [/player/manage/inventory/swap](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L21) | {identifier, invSlot, token} | {player}
PUT | [/player/manage/personality/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePersonality.coffee#L9) | {identifier, newPers, token} | {}
PUT | [/player/manage/personality/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePersonality.coffee#L15) | {identifier, oldPers, token} | {}
PUT | [/player/manage/priority/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L9) | {identifier, stat, points, token} | {player}
POST | [/player/manage/priority/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L21) | {identifier, stat, points, token} | {player}
PUT | [/player/manage/priority/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L15) | {identifier, stats, token} | {player}
POST | [/player/manage/pushbullet/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePushbullet.coffee#L14) | {identifier, token} | {}
PUT | [/player/manage/pushbullet/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePushbullet.coffee#L8) | {identifier, apiKey, token} | {}
PUT | [/player/manage/shop/buy](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageShop.coffee#L9) | {identifier, shopSlot, token} | {player}
POST | [/player/manage/string/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageString.coffee#L14) | {identifier, type, token} | {}
PUT | [/player/manage/string/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageString.coffee#L8) | {identifier, type, msg, token} | {}
POST | [/player/manage/tax](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L80) | {identifier, taxPercent, token} | {player}
POST | [/player/manage/title/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageTitle.coffee#L14) | {identifier, token} | {}
PUT | [/player/manage/title/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageTitle.coffee#L8) | {identifier, newTitle, token} | {}


Parameter | Type | Definition | Restrictions
--- | --- | --- | ---
[battleId](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Battle.coffee#L6) | string | The id representing the battle | 16 character Mongo ID
[identifier](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L11) | string | The players unique identifier | None
[password](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L13) | string | The token issued to the player on login | >3 characters
[token](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L12) | string | The token issued to the player on login | None


Return Value | Type | Description
--- | --- | ---
[battle](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Battle.coffee#L8) | object | The battle object
[player](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L15) | object | The player object
[token](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L16) | string | The players temporary secure token


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