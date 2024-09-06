extends "res://scripts/ui/level_select/level_select_entry.gd"

var map_file

func _ready():
	_play_button.pressed.connect(ModLoader.set_next_level_config.bind(_level_data))
	print("YES AAA AAA")
	print("\n\n\n")
	print("\n\n\n")
	print("\n\n\n")
	super._ready()
	
	
	
