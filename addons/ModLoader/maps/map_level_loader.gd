extends Level

var new_func_godot_map: FuncGodotMap
@onready var nav_region = $NavigationRegion3D

var audio_player: AudioStreamPlayer


func _ready():
	# we have to make our own func godot node so we take take over the texture loading
	new_func_godot_map = load("res://addons/ModLoader/maps/overrides/func_godot_map.gd").new()
	self.add_child(new_func_godot_map)

	new_func_godot_map.map_settings = load("res://addons/ModLoader/maps/map_settings.tres")
	new_func_godot_map.add_to_group("navigation_mesh_source_group")

	# now that we have a node we can set things up for the runtime build
	await get_tree().physics_frame
	new_func_godot_map.connect("build_complete", _build_complete)
	new_func_godot_map.connect("build_failed", _build_failed)
	new_func_godot_map.connect("unwrap_uv2_complete", _unwrap_uv2_complete)
	nav_region.connect("bake_finished", _bake_nav_finished)

	# we need to know the path to the map file
	self.config = ModLoader.current_config
	self.name = self.config.level_name
	var map = ModLoader.map_by_index[config.level_index]
	var path = map.path

	ModLoader.debug_log("my current name is " + name)

	if map.music_path:
		var audio_stream := AudioStreamMP3.load_from_file(map.music_path)
		audio_player = AudioStreamPlayer.new()
		audio_player.stream = audio_stream
		audio_player.autoplay = true
		audio_player.finished.connect(_on_audio_playing_finished)
		self.add_child(audio_player)

	# now we build
	new_func_godot_map.global_map_file = path
	ModLoader.debug_log("Path is %s" % path)
	ModLoader.debug_log("Config is %s" % config)
	ModLoader.debug_log(new_func_godot_map.verify_parameters())
	new_func_godot_map.verify_and_build()


func _build_complete() -> void:
	ModLoader.debug_log("Success! Unwrapping UV2...")
	new_func_godot_map.unwrap_uv2()


func _build_failed() -> void:
	printerr("Failed to build the map file! :(")


func _unwrap_uv2_complete() -> void:
	ModLoader.debug_log("UV2 unwrapping completed!")
	nav_region.bake_navigation_mesh()


func _bake_nav_finished():
	ModLoader.debug_log("Nav bake finished")
	super._ready()


func _on_audio_playing_finished():
	audio_player.play()
