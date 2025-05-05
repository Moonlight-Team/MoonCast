# MoonCast module for Fusion Engine
This is a port of MoonCast to [Fusion Engine](https://github.com/TheFusionEngine/FusionEngine) as an engine module. Currently, this port is a WIP, but when it is done it should provide identical functionality (and more) in comparison to the current Godot 4.4 port, but in C++, offering much better performance, cleaner code, and API improvements.

# Compiling
To use it, add the `mooncast` folder to the `modules` folder in your local copy of the Fusion Engine source code, and compile the engine to whichever platform/configuration you want. So far, it has only been tested on Linux, but it should work on most other platforms.

# Usage
This module will add the MoonCast classes to the engine itself, meaning that in your project, you should *not* have the `MoonCast` folder present in your project (it will create name conflicts). Other than that, it is MoonCast as you'd come to expect, running on Fusion Engine.

# Progress
Currently, there is a list of things that need to be implemented into Fusion, and a set of things that need to be implemented into MoonCast, in order for this port to be completed. This list is not comprehensive.
## Fusion Engine:
* GDScript from Godot 4 backported
## MoonCast:
* Collision detection