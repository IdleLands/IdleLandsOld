Simple Variables
================
Some events have custom text to indicate what happened, and who it happened to, and it can turn gender variables into the correct gender. These most often revolve around simple data for the player.

Dynamic Variables
=================
You can also specify dynamic variables, denoted with their encapsulation in `$`. They are split into domains, which have functions. You can also pass arguments to those functions (where applicable), and you can store results for later usage in a string. The general syntax is as follows:

```
$domain:function:arguments#cacheKey$
```

**Please note**, when specifying arguments, you should not put ANY spaces in your JSON. Additionally, all keys should be **single** quoted (not double quoted).

However, some calls are extended to allow you to 'dig' into the parent, like the party call:

```
$random:party#0 party:member#0$
```

Below is a full listing of calls. Please note, anything in the `dict` domain can be lowercase or Capitalized to get an appropriately-cased word (ie, you can do `$dict:noun` or `$dict:Noun$`).

Simple Variable | Returns
--- | ---
[%Heshe](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L325) | the gender of the player involved in the event, in the form of "He", "She", or "It"
[%Himher](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L319) | the gender of the player involved in the event, in the form of "Him", "Her", or "Theirs"
[%Hisher](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L316) | the gender of the player involved in the event, in the form of "His", "Her", or "Their"
[%Hishers](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L313) | the gender of the player involved in the event, in the form of "His", "Hers", or "Theirs"
[%She](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L322) | alias for %Heshe
[%gold](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/GoldEvent.coffee#L30) | the amount of gold gained (only applies to events that involve gold)
[%guildMember](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L292) | a random member from the current players guild, or a random player if not in a guild
[%guild](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L295) | the name of the current players guild, or a random guild if the player is not in a guild
[%heshe](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L310) | the gender of the player involved in the event, in the form of "he", "she", or "it"
[%himher](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L304) | the gender of the player involved in the event, in the form of "him", "her", or "theirs"
[%hisher](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L301) | the gender of the player involved in the event, in the form of "his", "her", or "their"
[%hishers](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L298) | the gender of the player involved in the event, in the form of "his", "hers", or "theirs"
[%item](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/EnchantEvent.coffee#L101) | the name of the item affected (only applies to events that involve items)
[%partyMembers](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/PartyEvent.coffee#L37) | the string that represents the members of the party (not counting the leader; use %player for that)
[%partyName](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/PartyEvent.coffee#L40) | the name of the party involved in the event
[%pet](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L289) | the name of the players pet, or placeholder text if the player doesn't have a pet
[%player](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L286) | the name of the player involved in the event (if any)
[%she](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L307) | alias for %heshe
[%xp](https://github.com/IdleLands/IdleLands/blob/master/src/event/singles/XpEvent.coffee#L30) | the amount of experience gained (only applies to events that involve xp)


Dynamic Variable | Returns
--- | ---
[$combat:party party:member$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L53) | A random member from a random party
[$combat:party$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L52) | A random party name
[$dict:Adjective$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L81) | A random, uppercase adjective
[$dict:Article$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L84) | A random, uppercase article
[$dict:Conjunction$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L85) | A random, uppercase conjunction
[$dict:Noun$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L82) | A random, uppercase noun
[$dict:Nouns$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L83) | A random, uppercase, plural noun
[$dict:Preposition$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L86) | A random, uppercase preposition
[$dict:adjective$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L74) | A random adjective
[$dict:article$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L77) | A random article
[$dict:conjunction$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L78) | A random conjunction
[$dict:noun$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L75) | A random, lowercase noun
[$dict:nouns$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L76) | A random, lowercase, plural noun
[$dict:preposition$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L79) | A random preposition
[$random:activePet$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L19) | A random, active pet name
[$random:deity$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L88) | A random deity and their flavor text
[$random:guild$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L28) | A random guild name
[$random:ingredient$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L46) | A random ingredient
[$random:ingredient:{'type':ingType}$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L47) | A random ingredient of the type ingType
[$random:item$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L36) | A random item
[$random:item:{'type':itemType}$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L37) | A random item of the type itemType
[$random:map$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L32) | A random map name
[$random:monster$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L42) | A random monster name
[$random:pet$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L15) | A random pet name
[$random:placeholder$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L12) | A random piece of placeholder text
[$random:player$](https://github.com/IdleLands/IdleLands/blob/master/src/system/handlers/MessageCreator.coffee#L24) | A random player name


**Additionally**, [the whole ChanceJS API](http://chancejs.com/) is available for use within the `chance` domain, ie, `$chance:name:{'middle':true}$`

CacheKey availability notes:
* When dealing with parties, it is not guaranteed to have a party. Empty parties are replaced with placeholder text.
* When dealing with parties in combat, you are not guaranteed to have more than 2 parties.
* When dealing with party members, it is not guaranteed to have more than 1 member (located at `#0`). The leader will always be at position 0. If you dig too deep (ie, `#10` is probably too far), then you will get placeholder text.