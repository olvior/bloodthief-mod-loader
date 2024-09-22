# Mod loader for Bloodthief (Playtest)

This is a map loader for Bloodthief

## Get started making a map

To get started making a map, you'll have to start by setting up TrenchBroom.
First install [TrenchBroom](https://trenchbroom.github.io/)

- First, download the zip called `map_creation_files`.
- Then unzip it anywhere
- Then move the `Bloodthief.zip` file to the TrenchBroom game config folder 
    - Windows: C:\Users\<username>\AppData\Roaming\TrenchBroom\games
    - Linux: ~/.TrenchBroom/games
- Make sure the `Bloodthief` folder is inside the `games` folder
- Then open TrenchBroom, click new map, click open preferences, click Bloodthief, set the game path to the same path as where you moved the `Bloodthief.zip` file to.
- Create a map with Bloodthief
- All the textures and entities should be loaded

TODO: ADD LINK TO DOWNLOAD

## How to load your map

First use the mod loader installer [windows](https://github.com/olvior/bloodthief-mod-loader/releases/download/v0.5.0/bt_mod_installer.exe) [linux](https://github.com/olvior/bloodthief-mod-loader/releases/download/v0.5.0/bt_mod_installer.x86_64) and install the mod loader

Then download the [map creation files](https://github.com/olvior/bloodthief-mod-loader/releases/download/v0.5.0/map_creation_files.zip)

From the original `map_creation_files`, move the `maps` folder into your Bloodthief game folder that Steam downloaded Bloodthief into.
- You should edit the json file in the `example_map` folder within the `maps` folder
- Make sure the json file has the same name as the map file
- Rename the files and the folder for the name of your map, if you're making a map pack you can have multiple json and .map files in one folder
- If you're going to share the map prefix the folder name with your username to make sure they end up unique

Once you've done all that you're ready to load up a map file in Trenchbroom

Watch a trenbroom tutorial or read the manual to get started

But the basics are you can create shapes and give them textures to make the geometry.

Then for single point entities you drag them in from the side bar, these include enemies and keys.

Then for areas you right click on a piece of geometry, click add brush entites, and whatever you want, for example a checkpoint area.

On the side, for each entity, there key value pairs to edit, for example for a checkpoint area you edit the checkpoint index.

For some more complicated behavior, such as doors, you need a trigger area. Then change the target to the name of what it should trigger. Then a mover, which moves when it gets triggered is the door. Make sure to change the targetname to what you entered for the target.

More details:
- You can use any map format in TrenchBroom (I think), but just stick to valve if unsure
- There is no need to compile it to play the map, just have the map in a folder inside the maps folder, with a json file to accompany it

---

Feel free to help develop the mod loader itself or the mod installer.

Everything that I made is open source so you're free to do whatever, however Blargis's assets are copyrighted by him.

