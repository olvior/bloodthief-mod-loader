extends "res://scripts/ui/loading_screen.gd"


func _ready():
	super._ready()
	for i in range(100):
		print("WE'RE in")


func _fully_exit_loading_screen():
	super._fully_exit_loading_screen()
	for i in range(100):
		ModLoader.debug_log("in")

	for f in ModLoader.redo_input_event_subscribers:
		f.call()
