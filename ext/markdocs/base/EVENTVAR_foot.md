**Additionally**, [the whole ChanceJS API](http://chancejs.com/) is available for use within the `chance` domain, ie, `$chance:name:{'middle':true}$`

CacheKey availability notes:
* When dealing with parties, it is not guaranteed to have a party. Empty parties are replaced with placeholder text.
* When dealing with parties in combat, you are not guaranteed to have more than 2 parties.
* When dealing with party members, it is not guaranteed to have more than 1 member (located at `#0`). The leader will always be at position 0. If you dig too deep (ie, `#10` is probably too far), then you will get placeholder text.