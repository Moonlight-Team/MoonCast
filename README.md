# MoonCast Engine

#### A 2D and 3D Sonic physics engine for Godot 4, aiming to be modular, robust, and easy to use. 

![logo](https://github.com/Moonlight-Team/MoonCast/blob/main/mooncastlogo.svg)

#### DISCLAIMER: THIS SOFTWARE IS IN A PRE-RELEASE STATE AND IS SUBJECT TO POTENTIALLY LARGE AND BACKWARDS COMPATIBILITY BREAKING CHANGES DURING DEVELOPMENT

## Features:
* Seperate physics state implemented as a custom Resource type for easily making customized player node implementations.
* Pre-made 2D and 3D player node types:
  * Vector based velocity systems that supports any direction of gravity.
  * Tight and complementary integration into Godot's physics engines
  * Easy to use script API for adding and extending player abilities in a modular way.
  * Simple player Node setup similar to CharacterBody2D and CharacterBody3D, without any scene inheritance or hard-coded Node paths.
  * Configurable animation wrapper system that allows for code executed in tandem with specific animations.
* A framework of commonly used and useful game objects, that are simple and configurable

## Overview:

MoonCast uses a physics state, currently stored in `MoonCastPhysicsTable`, which is a custom Resource type. This handles the state and *generic* calculations of physics. This Resource type is then used in *implementations* of the player, of which MoonCast has two: `MoonCastPlayer2D` and `MoonCastPlayer3D`, which are for 2D and 3D respectively. This system allows for seamlessly matching physics behavior between 2D and 3D, as well as the ability for users to write custom player nodes that can still utilize the same underlying physics calculations.

The MoonCast physics state handles the the following systems:
* Ground state 
  * Walking/running (including slope calculations)
  * Rolling
  * Jumping
* Air state
  * Movement
  * Gravity
  * Air drag
* Determining which animations to be played

The player implementation classes, `MoonCastPlayer2D` and `MoonCastPlayer3D`, are the custom `CharacterBody`-based classes with which player nodes are built. On their own, they contain the code for:
* Polling player input.
* The `MoonCastAbility` system.
* The `MoonCastAnimation` system.
* Playing sound effects

**Intentionally, no other abilities, including spindashing, super forms, the drop dash, etc, are included in these base `MoonCastPlayer` classes.**

For those, MoonCast has a `MoonCastAbility` system. Inheriting instances of this `Node`-based class are added as children of a `MoonCastPlayer2D`/`MoonCastPlayer3D` node. This class provides several virtual function overrides called during various events in the physics processes of the player, while still having the access to the full scope of Godot Engine, allowing for near infinite and easy to configure runtime code additions to the character to which they are children of. 

Additionally, MoonCast also implements its own `MoonCastAnimation` resource used as a wrapper for all animations in the MoonCastPlayer implementations. This wrapper includes parameters for animation playback speed, customizing rotation parameters, and defining a custom collision shape that will be active during the animation, as well as other extendability options.

## Using MoonCast In Your Projects:

To add MoonCast to your project, simply copy the `MoonCast/` folder the root of your Godot 4.4+ project. 

Most information pertaining to specifics of the engine, such as the use of variables or functions, can be viewed within the Godot editor, via the in-engine (Class Reference) docs.

Furthermore, in `addons/`, there is a Godot editor plugin that adds a `MoonCast Docs` main screen to your editor, which contains supplementary information about things not described in the Godot Class Reference documentation, such as more detailed explanations of MoonCast's systems, and how to perform basic setup of player nodes. This plugin is entirely optional and can be removed or disabled if not needed, and you do *not* need this plugin to have the documentation that shows up natively in Godot's documentation system.

## The MoonCast Demo:

In this repository, under the `Demo/` folder, is a demo for MoonCast, demonstrating a basic 2D and basic 3D utilization of the engine. Also in this repo is a `Framework/` folder, which has a lot of extra files that will be useful for those looking for "framework-like" things, like pre-made objects. __*Nothing in the framework or demo is required for MoonCast Engine to function, and is merely provided for example and convenience.*__

The scripts/code of the demo are licensed under the same license as MoonCast Engine (MIT), and require no further crediting then that of MoonCast itself. 

The sprites, tiles, audio, etc. of the demo are **NOT** licensed under the same license as the code. Please refrain from using those in your project without getting explicit prior permission from the Moonlight Team.

The one exception is the splash video found in `video/`, which can be used as an option for crediting MoonCast.

## Credits:
### MoonCast Engine:
* The [Sonic Retro Sonic Physics Guide](https://info.sonicretro.org/Sonic_Physics_Guide), for a LOT (and I mean a **LOT**) of physics behavior referencing. 
* [Flow Engine (and by extension, coderman64)](https://github.com/coderman64/flow-engine/tree/godot-4): Some code used as a basis for the legacy 2D engine physics, as well as general inspiration on project organization.
* [Hyper Framework (and by extension, Time209)](https://github.com/Time-rgb-dev): A reference for the handling of certain things in the 3D portion of the Engine, and also inspiration for the general 2nd iteration of the Engine's internal design.
* [Sonic Worlds Next](https://github.com/Techokami/SonicWorldsNext): Motivation for the creation of this engine, and the derivation of some ideas/concepts (such as the physics tables).
* [Godot Engine](https://github.com/godotengine/godot): Being an excellent basis for projects like this.
* Sonic Moonlight: The fangame that served as a catalyst for this engine to come into fruition.
* [KlashiCola](https://github.com/Klashicola): Engine assets, programming.
* [c08oprkiua](https://github.com/c08oprkiua): Main programmer.
* [GhoulX](https://github.com/Ghoul-webp): Editor icons, tweaked spindash speeds.
* [FrostyFoxTeals](https://github.com/Real-FrostyFoxTeals): Playtesting.
### Demo/Framework:
* [KlashiCola](https://github.com/Klashicola): 3D modeling.
* [SS](https://github.com/SS-SoStupid): Sonic sprites, level art, 3D modeling.
* .[GhoulX](https://github.com/Ghoul-webp) Concept Art, promotional art.
* [FrostyFoxTeals](https://github.com/Real-FrostyFoxTeals): Playtesting, level design.
* [c08oprkiua](https://github.com/c08oprkiua): Level design, ability programmer.
