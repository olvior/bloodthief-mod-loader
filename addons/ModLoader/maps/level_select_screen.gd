extends "res://scripts/ui/level_select/level_select_screen.gd"

func _populate_level_entries():
	super._populate_level_entries()
	
	for child in level_entries_parent.get_children():
		ModLoader.debug_log(child)
		child._play_button.pressed.connect(ModLoader.set_next_level_config.bind(child._level_data))
