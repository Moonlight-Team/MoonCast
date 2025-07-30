# Is MoonCast quick to set up or migrate to?
Yes! A basic, fresh `MoonCastPlayer` controller scene can be set up in only a minute or two, and it's easy to extend the player with Ability nodes. If your player has existing animations, whether they play through an `AnimationPlayer` (and `Sprite2D`) node or an `AnimatedSprite2D` node, they will be usable with MoonCast. 
# Is it configurable?
Yes, extremely! The physics table that is used for storing physics behavior (eg. Air/ground acceleration and deceleration, player gravity, etc.) is an easily swappable Resource type, and (possibly) required children like the `AnimationPlayer` can be manually selected on the Player node, so you don't need very strict scene structures.
# Does it have documentation?
Yes! In the `addons` folder, there is a plugin for adding in-editor documentation which explains how MoonCast's systems and nodes work.
# Does it run well?
Yes. I have tested MoonCast on machines with CPUs that clock in at less than 1GHz, and it ran perfectly. With the upcoming port to Fusion Engine and C++, it should run even better than it already does as well, with the aim being to run full speed on all platforms that Fusion Engine supports.
# Can I use this for other gameplay styles than "Classic Sonic"?
Yes! MoonCast's ability system makes it possible to add boost, stomp, and other abilities to the Player, which allows for many gameplay styles that divert from the "classic Sonic" formula. MoonCast can even be used for non Sonic games that still want Sonic-like physics (eg. Freedom Planet, Spark the Electric Jester). MoonCast on its own is extremely minimal, so you won't have to spend a lot of time stripping out features that you don't want.
# How do I credit this project?
 It's best to credit the project as "MoonCast" or perhaps "MoonCast Physics/Framework", since it is an open repository that several people can/will contribute to. Please do *not* credit MoonCast under just "Moonlight Team", as we are not guaranteed to be the sole contributors to MoonCast and that would not be fair to those external contributors.
# Can I use code in the Framework folder for my project? 
Of course! It is MIT licensed like the rest of the code, and crediting MoonCast itself (as explained above) should suffice for any usage of it.
# I can't find the feature I want in the `Framework` folder, does this mean MoonCast can't do it?
In most cases, no. The Framework is not a conclusive list of what MoonCast can do: If a feature you want is not present in it, it does not mean MoonCast is incapable of having the feature you were looking for. If you implement a feature and want to contribute it back to the main repo for others to use, feel free to make a PR!