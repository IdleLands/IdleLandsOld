Idle Lands
=========

An incremental game (read: idling) where you do nothing while your character fights to be the best in the realm. 

It can be run with a backend of IRC, or a console, or really just about anything you plug into it. I'm sure it'd be pretty cool if you hooked it up to a MeteorJS backend (I did this for the [web view](http://kurea.link/idle))! Currently, I use it as a module for my IRC bot, [Kurea](https://github.com/kellyirc/kurea) -- nothing special.

Developing
==========

Want to help develop Idle Lands? Great! Testing is super easy, as you can do it right in your console (or, go the more painful route and test it in IRC)!

Here are the prerequisites:

* coffee-script (npm install -g coffee-script)
* grunt (npm install -g grunt-cli)
* MongoDB

Then do:

```
git clone https://github.com/seiyria/IdleLands.git
npm install
npm start
```

While writing code, make sure it passes `coffeelint` -- the easy shortcut for this is `grunt dev`.

Adding Content
==============

Want to add content such as Classes, Personalities, Spells, or anything like that? Check out the [wiki](https://github.com/seiyria/IdleLands/wiki) for all of the existing documentation on events and functions available.
