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
 PATCH | /custom/mod/approve | {identifier} | {}
 POST | /custom/mod/list | {identifier} | {customs}
 PATCH | /custom/mod/reject | {identifier} | {}
 PUT | /custom/player/submit | {identifier, data
 POST | /custom/redeem | {identifier, crierId, giftId} | {}
 POST | /game/battle | {battleId} | {battle}
 POST | /game/map | {map} | {map}
 PUT | /guild/building/construct | {identifier, building, slot, token} | {player}
 POST | /guild/building/upgrade | {identifier, building, token} | {player}
 PUT | /guild/create | {identifier, guildName, token} | {guild}
 POST | /guild/invite/manage | {identifier, accepted, token} | {guild}
 PUT | /guild/invite/player | {identifier, invName, token} | {guild}
 POST | /guild/leave | {identifier, token} | {guild}
 PUT | /guild/leave | {identifier, token} | {guild}
 POST | /guild/manage/buff | {identifier, type, tier, token} | {guild}
 POST | /guild/manage/demote | {identifier, memberName, token} | {guild}
 POST | /guild/manage/donate | {identifier, gold, token} | {}
 POST | /guild/manage/kick | {identifier, memberName, token} | {guild}
 POST | /guild/manage/promote | {identifier, memberName, token} | {guild}
 POST | /guild/manage/tax | {identifier, taxPercent, token} | {guild}
 PUT | /guild/move | {identifier, newLoc, token} | {player}
 GET | /img/tiles.png | {} | IdleLands Tileset
 PUT | /pet/buy | {identifier, type, name, attrs, token} | {}
 PATCH | /pet/class | {identifier, petClass, token} | {}
 PUT | /pet/feed | {identifier, token} | {}
 PUT | /pet/inventory/equip | {identifier, itemSlot, token} | {}
 PUT | /pet/inventory/give | {identifier, itemSlot, token} | {}
 PATCH | /pet/inventory/sell | {identifier, itemSlot, token} | {}
 POST | /pet/inventory/take | {identifier, itemSlot, token} | {}
 POST | /pet/inventory/unequip | {identifier, itemUid, token} | {}
 PUT | /pet/smart | {identifier, option, value, token} | {}
 PATCH | /pet/swap | {identifier, petId, token} | {}
 POST | /pet/takeGold | {identifier, token} | {}
 POST | /pet/upgrade | {identifier, stat, token} | {}
 POST | /player/action/teleport | {identifier, newLoc, token} | {}
 POST | /player/action/turn | {identifier, token} | {player, pet}
 POST | /player/auth/login | {identifier, password} | {player, token}
 POST | /player/auth/logout | {identifier, token} | {}
 POST | /player/auth/password | {identifier, password, token} | {}
 PUT | /player/auth/register | {identifier, name, password} | {player, token}
 PUT | /player/manage/gender/set | {identifier, gender, token} | {}
 PUT | /player/manage/inventory/add | {identifier, itemSlot, token} | {player}
 POST | /player/manage/inventory/sell | {identifier, invSlot, token} | {player}
 PATCH | /player/manage/inventory/swap | {identifier, invSlot, token} | {player}
 PUT | /player/manage/personality/add | {identifier, newPers, token} | {}
 PUT | /player/manage/personality/remove | {identifier, oldPers, token} | {}
 PUT | /player/manage/priority/add | {identifier, stat, points, token} | {player}
 POST | /player/manage/priority/remove | {identifier, stat, points, token} | {player}
 PUT | /player/manage/priority/set | {identifier, stats, token} | {player}
 POST | /player/manage/pushbullet/remove | {identifier, token} | {}
 PUT | /player/manage/pushbullet/set | {identifier, apiKey, token} | {}
 PUT | /player/manage/shop/buy | {identifier, shopSlot, token} | {player}
 PUT | /player/manage/string/set | {identifier, type, msg, token} | {}
 POST | /player/manage/string/set | {identifier, type, token} | {}
 POST | /player/manage/tax | {identifier, taxPercent, token} | {player}
 POST | /player/manage/title/remove | {identifier, token} | {}
 PUT | /player/manage/title/set | {identifier, newTitle, token} | {}


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