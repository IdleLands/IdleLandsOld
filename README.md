Idle Lands
=========

An incremental game (read: idling) where you do nothing while your character fights to be the best in the realm. 

It can be run with a backend of IRC, or a console, or really just about anything you plug into it. I'm sure it'd be pretty cool if you hooked it up to a MeteorJS backend (I did this for the [web view](http://kurea.link/idle))! Currently, I use it as a module for my IRC bot, [Kurea](https://github.com/kellyirc/kurea) -- nothing special.

Developing
==========

Want to help develop Idle Lands? Great! Testing is super easy, as you can do it right in your console (or, go the more painful route and test it in IRC)!

Here are the prerequisites:

* MongoDB, Git, and npm
* coffee-script (npm install -g coffee-script)
* grunt (npm install -g grunt-cli)

Then do:

```
git clone https://github.com/seiyria/IdleLands.git
npm install
npm start
```

##Important##
While writing code, make sure it passes `coffeelint` -- the easy shortcut for this is `grunt dev`.

##Another Note##
Feel free to join us in irc.esper.net ##idlebot and chat with the devs and designers!

Adding Content
==============

Want to add content such as Classes, Personalities, Spells, or anything like that? Check out the [wiki](https://github.com/seiyria/IdleLands/wiki) for all of the existing documentation on events and functions available.

#Debugging#

While running LocalTest.coffee, you may press [ENTER] to enter an interactive session. This will pause the execution and allow you to execute code. By calling *getWrapper()*, you will be able to access the IdleGameWrapper object.

###Examples###
####Change a player's gold####
```
 %pm%=getWrapper().api.gameInstance.playerManager
 %pm%.players[0].addGold1\(100)
```
####Generate a party name####
```
getWrapper().api.gameInstance.playerManager.players[0].party.pickPartyName()
> Many Brave Peasants
%lc%  (Special variable, returns the last command you entered)
> Omnipotent Fear Near Darkness
```

####Force a battle to start####
```
%gi%=getWrapper().api.gameInstance
%pm%=%gi%.playerManager
%gi%.createParty(%pm%.players[0])
%gi%.createParty(%pm%.players[1])
%gi%.startBattle(%gi%.parties[0],%gi%.parties[1])
c
> A battle is raging...
```

####Cause any event to happen####
```
getWrapper().api.game.doEvent('Danret', 'enchant')
getWrapper().api.game.doEvent('Danret', 'blessItem')
```
