extends "res://addons/ModLoader/mod_node.gd"


func init():
	ModLoader.mod_log(name_pretty + " mod loaded")
	
func _ready():
	ModLoader.mod_log(path_to_dir + "/proper_config.tres")
	var level_config = load(path_to_dir + "/proper_config.tres")
	level_config.scene_path = path_to_dir + "/proper.tscn"
	GameManager._level_configs.append(level_config)
