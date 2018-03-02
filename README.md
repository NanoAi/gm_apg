# gm_apg
APG - A light weight, easy to use solution to help stop prop griefing on your server

![- APG - Light Weight, Easy to Use, Stops Crashes](https://i.imgur.com/BK0N7jj.jpg "APG - Light Weight, Easy to Use, Stops Crashes")

The development of APG was focused around the ability to provide a lightweight and efficient security against griefers whilst ensuring enough freedom to friendly players.

The main idea was to allow everyone to play with unfrozen props, thus every not frozen prop_physics will be set to collision group debris; that way, prop_physics won't collide with each other but can interact with world, players and static stuff.
I often take as example players playing soccer ( ball = prop_physics), the ball will collide with players and goals (frozen stuff) but not with other unfrozen stuff (to avoid any exploit).

Compatibility :
APG is not meant to handle prop ownability, thus APG is made to work along side with a prop protection addon such as        Falco's Prop Protection (FPP) or other Prop Protection addon.

It should work as soon as these are using Common Prop Protection Interface (CPPI).
    
Tested Prop Protection addons:
* Falco's Prop Protection (FPP)
* PatchProtect ( download it now - nil on CPPIcanPhysgun issue fixed ! Thanks to Domii894)

# WARNING: Don't use more then one prop protection addon at a time!

![- FEATURES -](https://i.imgur.com/IM0forg.jpg "Features")

* Easy install and configuration ( use the ingame menu : !apg )
* Customizable blacklist of entities to protect ( props, wire, etc)
* Props ghosting/unghosting on physgun
* Disable prop damage
* Blocks prop push against players
* Blocks prop push against vehicles
* Blocks prop fly/surf
* Blocks many kind of prop collision exploit
* Blocks stacker spam collisions
* Blocks Advanced Duplicator spam collisions exploit
* Ability to block vehicles damages against players
* Ability to make vehicles not collide with players
* Allows to block physgun mass unfreeze (Physgun Reload)
* Allows to block moving contraptions (props that are welded together)
* Supports anti-trapping for fading doors.
* Send a message to admins when a large stack of props is detected

Lag triggers are based on fancy algorithms and timers, if you are getting false positives try messing around with the values.

If you find any issue, exploit, possible improvement, suggestions, feel free to make an issue!

Credits:
* This project is currently updated and maintained by [LuaTenshi](http://steamcommunity.com/profiles/76561198096713277)
* This addon was originally created by [WhileTrue](http://steamcommunity.com/profiles/76561197972967270)
