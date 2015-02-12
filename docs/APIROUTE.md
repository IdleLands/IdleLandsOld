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
PATCH | [/custom/mod/approve](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L25) | {identifier} | {}
POST | [/custom/mod/list](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L19) | {identifier} | {customs}
PATCH | [/custom/mod/reject](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L31) | {identifier} | {}
PUT | [/custom/player/submit](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L7) | {identifier, data
POST | [/custom/redeem](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageCustomContent.coffee#L13) | {identifier, crierId, giftId} | {}
POST | [/game/battle](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Battle.coffee#L6) | {battleId} | {battle}
POST | [/game/map](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Map.coffee#L7) | {map} | {map}
PUT | [/guild/building/construct](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L87) | {identifier, building, slot, token} | {player}
POST | [/guild/building/upgrade](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L93) | {identifier, building, token} | {player}
PUT | [/guild/create](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L9) | {identifier, guildName, token} | {guild}
POST | [/guild/invite/manage](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L35) | {identifier, accepted, token} | {guild}
PUT | [/guild/invite/player](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L29) | {identifier, invName, token} | {guild}
POST | [/guild/leave](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L15) | {identifier, token} | {guild}
PUT | [/guild/leave](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L21) | {identifier, token} | {guild}
POST | [/guild/manage/buff](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L67) | {identifier, type, tier, token} | {guild}
POST | [/guild/manage/demote](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L49) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/donate](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L61) | {identifier, gold, token} | {}
POST | [/guild/manage/kick](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L55) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/promote](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L43) | {identifier, memberName, token} | {guild}
POST | [/guild/manage/tax](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L73) | {identifier, taxPercent, token} | {guild}
PUT | [/guild/move](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L99) | {identifier, newLoc, token} | {player}
GET | [/img/tiles.png](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/REST.coffee#L37) | {} | IdleLands Tileset
PUT | [/pet/buy](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L9) | {identifier, type, name, attrs, token} | {}
PATCH | [/pet/class](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L45) | {identifier, petClass, token} | {}
PUT | [/pet/feed](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L21) | {identifier, token} | {}
PUT | [/pet/inventory/equip](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L69) | {identifier, itemSlot, token} | {}
PUT | [/pet/inventory/give](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L51) | {identifier, itemSlot, token} | {}
PATCH | [/pet/inventory/sell](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L63) | {identifier, itemSlot, token} | {}
POST | [/pet/inventory/take](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L57) | {identifier, itemSlot, token} | {}
POST | [/pet/inventory/unequip](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L75) | {identifier, itemUid, token} | {}
PUT | [/pet/smart](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L33) | {identifier, option, value, token} | {}
PATCH | [/pet/swap](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L39) | {identifier, petId, token} | {}
POST | [/pet/takeGold](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L27) | {identifier, token} | {}
POST | [/pet/upgrade](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePet.coffee#L15) | {identifier, stat, token} | {}
POST | [/player/action/teleport](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/PlayerActions.coffee#L7) | {identifier, newLoc, token} | {}
POST | [/player/action/turn](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/TurnAction.coffee#L8) | {identifier, token} | {player, pet}
POST | [/player/auth/login](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L26) | {identifier, password} | {player, token}
POST | [/player/auth/logout](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L19) | {identifier, token} | {}
POST | [/player/auth/password](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L33) | {identifier, password, token} | {}
PUT | [/player/auth/register](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/Authentication.coffee#L11) | {identifier, name, password} | {player, token}
PUT | [/player/manage/gender/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGender.coffee#L7) | {identifier, gender, token} | {}
PUT | [/player/manage/inventory/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L8) | {identifier, itemSlot, token} | {player}
POST | [/player/manage/inventory/sell](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L14) | {identifier, invSlot, token} | {player}
PATCH | [/player/manage/inventory/swap](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageInventory.coffee#L20) | {identifier, invSlot, token} | {player}
PUT | [/player/manage/personality/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePersonality.coffee#L8) | {identifier, newPers, token} | {}
PUT | [/player/manage/personality/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePersonality.coffee#L14) | {identifier, oldPers, token} | {}
PUT | [/player/manage/priority/add](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L8) | {identifier, stat, points, token} | {player}
POST | [/player/manage/priority/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L20) | {identifier, stat, points, token} | {player}
PUT | [/player/manage/priority/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePriority.coffee#L14) | {identifier, stats, token} | {player}
POST | [/player/manage/pushbullet/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePushbullet.coffee#L13) | {identifier, token} | {}
PUT | [/player/manage/pushbullet/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManagePushbullet.coffee#L7) | {identifier, apiKey, token} | {}
PUT | [/player/manage/shop/buy](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageShop.coffee#L8) | {identifier, shopSlot, token} | {player}
POST | [/player/manage/string/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageString.coffee#L13) | {identifier, type, token} | {}
PUT | [/player/manage/string/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageString.coffee#L7) | {identifier, type, msg, token} | {}
POST | [/player/manage/tax](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageGuild.coffee#L79) | {identifier, taxPercent, token} | {player}
POST | [/player/manage/title/remove](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageTitle.coffee#L13) | {identifier, token} | {}
PUT | [/player/manage/title/set](https://github.com/IdleLands/IdleLands/blob/master/src/system/accessibility/rest-routes/ManageTitle.coffee#L7) | {identifier, newTitle, token} | {}


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