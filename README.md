# APG - A light weight, easy to use solution to help stop prop griefing on your server

![- APG - Light Weight, Easy to Use, Stops Crashes](https://i.imgur.com/BK0N7jj.jpg "APG - Light Weight, Easy to Use, Stops Crashes")

The development of APG was focused around the ability to provide a lightweight and efficient security against griefers whilst ensuring enough freedom to friendly players.

The main idea is to allow everyone to use ufrozen props, so not every prop will be no collided; that way props won't collide with each other but can interact with the world, players, etc.

A good example is playing soccer, where the ball is a prop, the ball will collide with players and goals (frozen props) but not unfrozen props (to avoid exploits)

Compatibility :
APG is not meant to handle prop ownability, thus APG is made to work along side with a prop protection addons that use Common Prop Protection Interface (CPPI) as it's compatibility layer.
    
Prop Protection Addons that use CPPI:
* [Falco's Prop Protection (FPP)](https://github.com/FPtje/Falcos-Prop-protection/)
* [PatchProtect](https://github.com/Patcher56/PatchProtect)
* [Simple Prop Protection (SPP)](https://github.com/Donkie/SimplePropProtection)

# WARNING: Don't use more then one prop protection addon at a time!

![- FEATURES -](https://i.imgur.com/IM0forg.jpg "Features")

* Easy install and configuration ( use the ingame menu : !apg or apg in console )
* Customizable blacklist of entities to protect ( props, wire, etc)
* Props ghosting/unghosting on physgun
* Disables prop damage to players
* Blocks prop pushing players
* Blocks prop pushing vehicles
* Blocks prop surfing
* Blocks many kind of prop collision exploit
* Blocks stacker exploit
* Blocks fading door exploit
* Blocks Advanced Duplicator spam collisions exploit
* Blocks tool gun spamming
* Blocks tool gun being used on world
* Blocks the toolgun fron unfreezeing any props
* Ability to check entities around the prop for stack's
* Ability to block vehicles damages against players
* Ability to make vehicles not collide with players
* Allows to block physgun reload
* Allows to block moving contraptions (props that are welded together)
* Supports anti-trapping for fading doors.
* Send a message to admins when a large stack of props is detected

Lag triggers are based on fancy algorithms and timers, if you are getting false positives try messing around with the values.

If you find any issue, exploit, possible improvement, suggestions, feel free to make an issue!

Credits:
* This project is currently updated and maintained by [LuaTenshi](http://steamcommunity.com/profiles/76561198096713277)
* This addon was originally created by [WhileTrue](http://steamcommunity.com/profiles/76561197972967270)
