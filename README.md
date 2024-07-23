# MoonCast Engine
#### A 2D and 3D Sonic physics engine for Godot 4, aiming to be modular, robust, and easy to use. 

## Features:
* Both 3D and 2D character support
* Tight and complementary integration into Godot's systems, including collision and physics
* Custom Resource types that can be used for both the 3D and 2D systems.
* An ECS for creating modular character abilities
* Highly configurable APIs

## Overview:

MoonCast uses physics tables, in the form of a custom Resource class called `MoonCastPhysicsTable`. This one physics table is used by both the 2D and 3D player characters. Coupled with the 3D and 2D physics being intentionally similarly designed, this allows for seamless matching physics controlling between 2D and 3D. 

The player character classes, `MoonCastPlayer2D` and `MoonCastPlayer3D`, are the custom `CharacterBody`-based classes with which characters are built. On their own, they contain the code for momentum-based movement (including slope calculations), rolling, jumping, and triggering animations (either for an automatically detected `AnimationPlayer` child or `AnimatableSprite2D` child). **Intentionally, no other abilities, including spindashing, super forms, the drop dash, etc, are included in these base classes.**

For those, MoonCast has its own ECS (Entity Component System) for character abilities. Each ability is derived from a base Node-derived `MoonCastAbility` class, and are added to player characters by adding them as children of the player character node. This class provides several hooks into the physics processes of the characters, allowing for near infinite runtime configuration of the physics of the character to which they are children of. 

Most other information pertaining to specifics of the engine, such as the use of variables or functions, can be viewed within Godot with the editor, via the in-engine docs.

## Credits:
* [Flow Engine (and by extension, its contributors)](https://github.com/coderman64/flow-engine/tree/godot-4): Some code used as a basis for the 2D engine physics, as well as general inspiration on project organization.
* [Sonic Worlds Next](https://github.com/Techokami/SonicWorldsNext): Inspiration for the creation of this engine, and the derivation of some ideas/concepts (such as the physics tables)
* [Godot Engine](https://github.com/godotengine/godot): Being an excellent basis for projects like this 
* Sonic Moonlight: The fangame that served as a catalyst for this engine to come into fruition.
* [KlashiCola](https://github.com/Klashicola): Original assets
* [c08oprkiua](https://github.com/c08oprkiua): Main programmer
