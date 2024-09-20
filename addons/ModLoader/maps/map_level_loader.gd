extends Level

@onready var func_godot_map := $FuncGodotMap as FuncGodotMap
@onready var nav_region = $NavigationRegion3D

func _ready():
	await get_tree().physics_frame
	func_godot_map.connect("build_complete", _build_complete)
	func_godot_map.connect("build_failed", _build_failed)
	func_godot_map.connect("unwrap_uv2_complete", _unwrap_uv2_complete)
	nav_region.connect("bake_finished", _bake_nav_finished)
	
	config = ModLoader.current_config
	var path = ModLoader.map_file_by_index[config.level_index]
	
	print(func_godot_map.map_settings.entity_fgd)
	print(len(func_godot_map.map_settings.entity_fgd.entity_definitions))
	print(func_godot_map.map_settings.entity_fgd.resource_path)
	for i in func_godot_map.map_settings.entity_fgd.entity_definitions:
		print(i.resource_path)
	
	func_godot_map.global_map_file = path
	print(path)
	print(func_godot_map.verify_parameters())
	func_godot_map.verify_and_build()

func _build_complete() -> void:
	print("Success! Unwrapping UV2...")
	func_godot_map.unwrap_uv2()

func _build_failed() -> void:
	printerr("Failed to build the map file! :(")

func _unwrap_uv2_complete() -> void:
	print("UV2 unwrapping completed!")
	nav_region.bake_navigation_mesh()

func _bake_nav_finished():
	print("Nav bake finished")
	super._ready()
