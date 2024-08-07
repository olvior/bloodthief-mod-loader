# Mod loader for Bloodthief (Playtest)

Use the installer to set up the mod loader and to install mods


## How does it work?

The mod loader is made up of two main parts: The `override.cfg` file and `addons/mod_loader.gd` file.

The `override.cfg` essentially acts like another `project.godot`, expect it will override the settings in the original `project.godot` if there is overlap.

The only thing the `override.cfg` file does is it creates an autoload that launches the `mod_loader.gd` script.

Once that script is launched, it searches through the `mods/` folder in the game's base directory for zip files that are mods, and in the `mods-unpacked/` folder for mods that are not zipped. Zips are for sharing them, and the unpacked ones are for development.

The script then creates a child node for each mod found and also calls the `init()` function.

## How to create a mod:

Create a folder with the structure `namespace-mod_name`, this is also your mod's id.

Within that folder create a `manifest.json` using the template found [here](https://github.com/olvior/bloodthief-mod-list/blob/main/manifest_template.json).

Then also create a `mod_main.gd` which needs an `init()` function.

Then you can run whatever code you want!

Your mod's files can be found at `res://mods-unpacked/your_mod_id/` when unpacked, or `res://your_mod_id/` when zipped. (Not indented just idk how to fix it)

## How to upload a mod to the mod installer:

Create a pr [here](https://github.com/olvior/bloodthief-mod-list/blob/main/list.json) and I'll accept it eventually. Then it should immediately show up in the mod installer.

---

Feel free to help develop the mod loader itself or the mod installer.

Everything is open source so you're free to do whatever.

