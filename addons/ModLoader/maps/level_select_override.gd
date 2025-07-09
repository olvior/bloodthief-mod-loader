extends "res://scripts/ui/level_select/level_select_entry.gd"

var map_file


func _ready():
	_play_button.pressed.connect(ModLoader.set_next_level_config.bind(_level_data))
	ModLoader.debug_log("Override level select loading")
	super._ready()
