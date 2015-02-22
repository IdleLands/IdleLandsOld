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