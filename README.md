# Encyclopedia Mechanica

This is the Encyclopedia Mechanica, an open-source collection of game mechanics intended to educate and inspire folks who want to make games or learn about them. Each mechanic comes with a description, controls, and a set of parameters that you can use to tweak and tune the mechanic's behavior.

Come find us on [Discord](https://discord.gg/6HYYNwq4FS)!

## Contributing

### Prereqs
* Godot 4.1.x Stable

### Guide

1) Take a look at Bobber Fishing or Pattern Crafting to see how we structure mechanics
1) Fork the repository
1) Use the Mechanic Manager Plugin (upper left) to create a new mechanic skeleton. You'll see that we create a scene for you, drop in the core UI, and create a data script. Properties on that data script are used to generate the configuration tab on mechanic pages - you'll see how it works in Bobber Fishing and Pattern Crafting.
1) Add your mechanic to `MechanicDatabase.gd`
1) Implement your mechanic
1) Create a thumbnail (screenshot is fine) and reference it in `MechanicDatabase.gd`
1) Test, polish, playtest, etc (a good time to review with the discord!)
1) Cleanup unused assets, fill out `description.txt` and `attributions.txt`
1) Create a pull request

A finished mechanic will have:
* A decent level of polish
* Content in `description.txt`
  * A description of the mechanic generally
  * How your implementation works
  * If applicable, links to videos and other content about games that have implemented the mechanic
* Appropriately licensed assets (see the Assets section below)
  * Fill out `attribution.txt` where appropriate
* No unused assets (eg textures, audio, scripts, etc that aren't in use)

### Assets
You are welcome to pull in third-party assets but you need to make sure that their license is compatible with the license on this project. Creating your own assets or using [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/) is the easiest way to do so.

The main way we deploy the Encyclopedia is through web export, so please try and re-use assets in the Shared folder where possible to keep the size of the library low.
