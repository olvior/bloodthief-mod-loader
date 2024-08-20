extends "res://addons/ModLoader/mod_node.gd"


func init():
	ModLoader.mod_log(name_pretty + " mod loaded")
	
func _ready():
	GameManager._level_configs.append(load(path_to_dir + "/proper_config.tres"))
