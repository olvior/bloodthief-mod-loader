extends Level

@onready var func_godot_map := $FuncGodotMap as FuncGodotMap

var entity_fgd = preload("res://func_godot/fgd/fgd_files/bloodthief_demo_fgd.tres")

func _ready():
	await get_tree().physics_frame
	self.config = ModLoader.current_config
	func_godot_map.connect("build_complete", _build_complete)
	func_godot_map.connect("build_failed", _build_failed)
	func_godot_map.connect("unwrap_uv2_complete", _unwrap_uv2_complete)
	
	config = ModLoader.current_config
	var path = ModLoader.map_file_by_index[config.level_index]
	
	func_godot_map.map_settings.entity_fgd = entity_fgd
	
	print(func_godot_map.map_settings.entity_fgd)
	print(len(func_godot_map.map_settings.entity_fgd.entity_definitions))
	print(func_godot_map.map_settings.entity_fgd.resource_path)
	for i in func_godot_map.map_settings.entity_fgd.entity_definitions:
		print(i.resource_path)
	
	func_godot_map.global_map_file = path
	func_godot_map.verify_and_build()

func _build_complete() -> void:
	print("Success! Not unwrapping UV2...")
	#func_godot_map.unwrap_uv2()
	super._ready()
	

func _build_failed() -> void:
	printerr("Failed to build the map file! :(")

func _unwrap_uv2_complete() -> void:
	print("UV2 unwrapping completed!")
