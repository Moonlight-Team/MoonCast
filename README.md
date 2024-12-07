# MoonCast Engine
#### A 2D and 3D Sonic physics engine for Godot 4, aiming to be modular, robust, and easy to use. 

![logo](https://github.com/Moonlight-Team/MoonCast/blob/main/mooncastlogo.svg)

## Features:
* Both 3D and 2D character support.
* Tight and complementary integration into Godot's systems, including collision and physics.
* Custom Resource types that can be used for both the 3D and 2D systems.
* Easy to use script API for adding and extending player abilities in a modular way.
* Highly configurable player node types.

## Overview:

MoonCast uses physics tables, in the form of a custom Resource class called `MoonCastPhysicsTable`. This one physics table is used by both the 2D and 3D player characters. Coupled with the 3D and 2D physics being intentionally similarly designed, this allows for seamless matching physics controlling between 2D and 3D. 

The player character classes, `MoonCastPlayer2D` and `MoonCastPlayer3D`, are the custom `CharacterBody`-based classes with which characters are built. On their own, they contain the code for:
* Momentum-based movement (including slope calculations)
* Rolling
* Jumping
* Playing sound effects
* Triggering animations (either for an automatically detected `AnimationPlayer` child, or when in 2D, a `AnimatedSprite2D` child). 

**Intentionally, no other abilities, including spindashing, super forms, the drop dash, etc, are included in these base `MoonCastPlayer` classes.**

For those, MoonCast has its `MoonCastAbility` system. Inheriting instances of this `Node`-based class are added as children of a `MoonCastPlayer2D`/`MoonCastPlayer3D` node. This class provides several virtual function overrides called during various events in the physics processes of the characters, while still having the access to the full scope of Godot Engine, allowing for near infinite and easy to configure runtime code additions to the character to which they are children of. 

Most other information pertaining to specifics of the engine, such as the use of variables or functions, can be viewed within the Godot editor, via the in-engine docs.

## Using MoonCast In Your Projects:

Copy the `/MoonCast` folder to somewhere in your Godot 4.4+ project. Yep, that's all, you have now added MoonCast to your project. 

If you would like the MoonCast Docs as a tab in your Godot editor, copy the `addons/` folder to your project. There is nothing in the contained plugin except for those docs, so this is optional. These are extra documents about the features of MoonCast itself, and are separate from the in-engine docs for the functions and variables, so you do *not* need this plugin to have the documentation that shows up natively in Godot's documentation system.

Feel free to reference the demo on implementations of the classes in MoonCast. The scripts in the demo are also available for use, and a lot of extra goodies not explicitly included in the demo are included in the `/Demo` folder for you to mess around with if you so choose. The *code* of MoonCast is under the MIT license, so please don't forget to credit MoonCast in your project. 

The `splash.ogv` video in `/video` is available to use as an optional splash screen for your project, and would count as the aforementioned crediting. 

The visual assets in the demo besides the aforementioned splash screen are NOT licensed under the same license as the code; please refrain from using those in your project without getting explicit prior permission from the Moonlight Team. 

## Credits:
### MoonCast Engine:
* The [Sonic Retro Sonic Physics Guide](https://info.sonicretro.org/Sonic_Physics_Guide), for a LOT (and I mean a **LOT**) of physics behavior referencing. 
* [Flow Engine (and by extension, coderman64)](https://github.com/coderman64/flow-engine/tree/godot-4): Some code used as a basis for the 2D engine physics, as well as general inspiration on project organization.
* [Sonic Worlds Next](https://github.com/Techokami/SonicWorldsNext): Inspiration for the creation of this engine, and the derivation of some ideas/concepts (such as the physics tables)
* [Godot Engine](https://github.com/godotengine/godot): Being an excellent basis for projects like this 
* Sonic Moonlight: The fangame that served as a catalyst for this engine to come into fruition.
* [KlashiCola](https://github.com/Klashicola): Engine assets, programming.
* [c08oprkiua](https://github.com/c08oprkiua): Main programmer.
* CyberFog: Editor icons.
* [FrostyFoxTeals](https://github.com/Real-FrostyFoxTeals): Playtesting.
### Demo:
* [KlashiCola](https://github.com/Klashicola): 3D modeling.
* [SS](https://github.com/SS-SoStupid): Sonic sprites, level art.
* CyberFog: Level art.
* [FrostyFoxTeals](https://github.com/Real-FrostyFoxTeals): Playtesting, level design.
* [c08oprkiua](https://github.com/c08oprkiua): Level design, ability programmer.
