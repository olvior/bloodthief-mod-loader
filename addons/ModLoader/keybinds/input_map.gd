extends "res://scripts/services/input_map_service.gd"


func load_input_map_from_save_or_default():
	super.load_input_map_from_save_or_default()

	for f in ModLoader.redo_input_event_subscribers:
		f.call()
