# Mod loader for Bloodthief (Demo)

This is a Map/Mod Loader for Bloodthief Demo.

## Do be advised that Mods could contain malicious code, so please make sure you're downloading them from Trusted Sources and check their source code.

Contents:

- [Get started making a map](#get-started-making-a-map)
- [How to load your map](#how-to-load-your-map)
- [How to use TrenchBroom](#how-to-use-trenchbroom)
- [More advanced map creation](#more-advanced-map-creation)
- [Uploading or sharing maps](#uploading-or-sharing-maps)
- [How to create a Mod](#how-to-create-a-mod)
- [Ending notes](#ending-notes)


## How does it work?

The mod loader is made up of two main parts: The `override.cfg` file and `addons/ModLoader/mod_loader.gd` file.

The `override.cfg` essentially acts like another `project.godot`, except it will override the settings in the original `project.godot` if there is overlap.

The only thing the `override.cfg` file does is it creates an autoload that launches the `mod_loader.gd` script.

Once that script is launched, it searches through the `mods/` folder in the game's base directory for zip files that are mods, and in the `mods-unpacked/` folder for mods that are not zipped. Zips are for sharing them, and the unpacked ones are for development.

The script then creates a child node for each mod found and also calls the `init()` function.

## Get started making a map

To get started making a map, you'll have to start by setting up TrenchBroom.
First install [TrenchBroom](https://trenchbroom.github.io/)

- First, download the zip called [`map_creation_files`](./map_creation_files).
- Then unzip it anywhere
- Then move the `Bloodthief.zip` file to the TrenchBroom game config folder
    - Windows: C:\Users\<username>\AppData\Roaming\TrenchBroom\games
    - Linux: ~/.TrenchBroom/games
- Make sure the `Bloodthief` folder is inside the `games` folder, then unzip it
- Then open TrenchBroom, click new map, click open preferences, click Bloodthief, set the game path to the same path as where you moved the `Bloodthief.zip` file to.
- Create a map with Bloodthief
- All the textures and entities should be loaded

## How to load your map

First use the mod loader installer [windows](https://github.com/olvior/bloodthief-mod-loader/releases/latest/download/bt_mod_installer.exe) [linux](https://github.com/olvior/bloodthief-mod-loader/releases/latest/download/bt_mod_installer.x86_64) and install the mod loader

Then download the [map creation files](./map_creation_files)

From the `map_creation_files`, move the `maps` folder into the game folder that Steam downloaded Bloodthief into.
- You should edit the json file in the `example_map` folder within the `maps` folder
- Make sure the json file has the same name as the map file
- Rename the files and the folder for the name of your map, if you're making a map pack you can have multiple json and .map files in one folder
- If you're going to share the map prefix the folder name with your username to make sure they end up unique

## How to use TrenchBroom

Once you've done all that, you're ready to load up a map file in TrenchBroom.

Watch a TrenchBroom tutorial or read the manual to get started.

But the basics are you can create shapes and give them textures to make the geometry.

Then for single point entities you drag them in from the side bar, these include enemies and keys.

Then for areas you right click on a piece of geometry, click add brush entities, and whatever you want, for example a checkpoint area.

On the side, for each entity, there key value pairs to edit, for example for a checkpoint area you edit the checkpoint index.

For some more complicated behavior, such as doors, you need a trigger area. Then change the target to the name of what it should trigger. Then a mover, which moves when it gets triggered is the door. Make sure to change the targetname to what you entered for the target.

More details:
- You can use any map format in TrenchBroom (I think), but just stick to valve if unsure
- There is no need to compile it to play the map, just have the map in a folder inside the maps folder, with a json file to accompany it


<br>**The file structure should look a bit like this:**
- Bloodthief folder
  - maps
    - <folder name, for this example let's call it "test">
      - test.json
      - test.map

## More advanced map creation

<br>To allow for custom textures, add them like this in your map folder:
- maps/
  - author-Name/
    - map.json
    - map.map
    - textures/
      - textureone.png
      - ...

Then for TrenchBroom to realise they exist, add them like so:
- *TrenchBroom folder*
  - games/
    - Bloodthief/
      - textures/
        - author-Name/
          - textureone.png
          - ...

Make sure to enable the folder in TrenchBroom. When you are in the face tab, in the texture browser click settings, then enable your folder

## Uploading or sharing maps

Compress your map as a zip file

For someone to play it they will have to unzip it in the `maps/` directory in the main Bloodthief directory


To upload it to the mod loader installer, upload the zip to github (or elsewhere). Then edit and create a pull request in [this file](https://github.com/olvior/bloodthief-mod-list/blob/main/map_list.json), update the json file based on your map's information. Some things like the dependencies or tags aren't used yet, but will probably be used in the future.

Once that pull request has been merged the map will be downloadable.


## How to create a mod:

Create a folder with the structure `namespace-mod_name`, this is also your mod's id or name.

Within that folder create a `manifest.json` using the template found [here](https://github.com/olvior/bloodthief-mod-list/blob/main/manifest_template.json).

Then also create a `mod_main.gd` which needs to extend `res://ModLoader/mod_node.gd`, it should inherit from `"res://addons/ModLoader/mod_node.gd"`.

Then you can run whatever code you want!

Your mod's files can be found at the variable `path_to_dir`.

There are a few helpful functions that you can use, `ModLoader.mod_log('text')` to log something in a separate file. You can create a new input easily. Check [`addons/ModLoader/mod_node.gd`](./addons/ModLoader/mod_node.gd) for the details.

You can also make settings that can be changed in game (wip) with the `Settings` class, check the example [infinite blood mod](./example_mods/mods-unpacked/olvior-InfiniteBlood/) to see how.

Additionally, see this [wiki](https://github.com/carlosfruitcup/bloodthief-modding-docs/wiki) for some documentation that can be used to help your modding endeavours.

Finally, you can uploads mods into the [`mod_list`](https://github.com/olvior/bloodthief-mod-list/blob/main/list.json) just like you can for maps.

## Ending notes

Feel free to help develop the mod loader itself or the mod installer.

Everything that we made here is open source so you're free to do whatever, however Blargis's assets are copyrighted by him.

