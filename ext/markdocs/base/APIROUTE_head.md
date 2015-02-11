IdleLands provides a REST API for developers to create external clients to interface with the game. Developers will have to make note of a few things, namely: you have to tell the game when you're taking your turn, and you will have a token that is generated every time you login, that you must use or subsequent requests will be denied. This is to avoid sending an identifier and password for every request.

Please note, the game does include a "heartbeat" mechanism, and if you do not send your next turn within 30 seconds, the game will log you out. External clients should include automatic login mechanisms for these situations, so players do not have to log back in manually.

There are also some API limits:
* You cannot have more than one turn in a 10-second span
* You cannot request more than one map in a 10-second span
* You cannot create more than one character every 24 hours

These limits only apply to each individual user of the client, not the client as a whole, so you can definitely have concurrent users for your client.

The base API url is http://api.idle.land (https also available) -- feel free to use this for testing! Just don't make too many characters, please.