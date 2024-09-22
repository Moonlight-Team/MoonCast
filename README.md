# MoonCast Engine
#### A 2D and 3D Sonic physics engine for Godot 4, aiming to be modular, robust, and easy to use. 

![logo](https://github.com/Moonlight-Team/MoonCast/blob/main/splash.png)

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

## Credits:
### MoonCast Engine:
* [Flow Engine (and by extension, its contributors)](https://github.com/coderman64/flow-engine/tree/godot-4): Some code used as a basis for the 2D engine physics, as well as general inspiration on project organization.
* [Sonic Worlds Next](https://github.com/Techokami/SonicWorldsNext): Inspiration for the creation of this engine, and the derivation of some ideas/concepts (such as the physics tables)
* [Godot Engine](https://github.com/godotengine/godot): Being an excellent basis for projects like this 
* Sonic Moonlight: The fangame that served as a catalyst for this engine to come into fruition.
* [KlashiCola](https://github.com/Klashicola): Original assets, programming
* [c08oprkiua](https://github.com/c08oprkiua): Main programmer
### Demo:
* [KlashiCola](https://github.com/Klashicola): 3D modeling
* SS: Sonic sprites, level art
* CyberFog: Level art
* [c08oprkiua](https://github.com/c08oprkiua): Level design