extends "res://addons/ModLoader/mod_node.gd"


func init():
	ModLoader.mod_log(name_pretty + " mod loaded")


	ModLoader.mod_log(str(dependencies) + " dep")
	var level_helper = dependencies["olvior-LevelHelper"]
	level_helper.create_level("Supercoollevel", 1, path_to_dir + "/testroom.tscn", "Super cool level", "supercoollevelboard", [10, 20, 30], true)
