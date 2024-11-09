extends CharacterBody3D

var func_godot_properties: Dictionary = {}
var custom_entity_path: String

var enemy_id: int = -1

@onready var hurt_comp = $HurtAndCollideComponent

func _func_godot_apply_properties(props: Dictionary)-> void:
	func_godot_properties = props
	custom_entity_path = props["custom_entity_path"]
	print(props)

#############
# lua stuff #
#############
var lua

func _lua_print(message) -> void:
	print(message)

func _lua_play_sound(sound_path: String) -> void:
	if not sound_path.get_extension() in ["mp3", "wav", "ogg"]:
		print("ERROR: Invalid sound path ", sound_path)
		return

	var sound = load(sound_path)
	
	var new_audio_player := AudioStreamPlayer.new()
	self.add_child(new_audio_player)

	new_audio_player.stream = sound
	new_audio_player.play()
	new_audio_player.finished.connect(kill_audio_player.bind(new_audio_player))
	

func kill_audio_player(audio_player):
	audio_player.queue_free()

func _lua_normalise(vector_arr):
	var vec := arr_to_vec(vector_arr)
	vec = vec.normalized()

	return vec_to_arr(vec)


func gen_basic_lua_object():
	var lua_instance := ClassDB.instantiate("LuaAPI")
	
	# some functions it should have
	lua_instance.push_variant("print", _lua_print)
	lua_instance.push_variant("mod_loader_play_sound", _lua_play_sound)
	lua_instance.push_variant("mod_loader_normalise", _lua_normalise)

	# All builtin libraries are available to bind with. Use OS and IO at your own risk.
	lua_instance.bind_libraries(["base", "table", "string"])

	return lua_instance


func vec_to_arr(vec: Vector3) -> Array:
	return [vec.x, vec.y, vec.z]

func arr_to_vec(arr: Array) -> Vector3:
	return Vector3(arr[0], arr[1], arr[2])

func _ready() -> void:
	lua = gen_basic_lua_object()

	lua.push_variant("func_godot_properties", func_godot_properties)

	var lua_str := FileAccess.get_file_as_string("res://addons/ModLoader/test.lua")

	var err = lua.do_string(lua_str)

	if err:
		printerr("ERROR %d: %s" % [err.type, err.message])
		return
	
	enemy_id = StatsService.register_enemy()


func _physics_process(delta):
	if not hurt_comp.is_dead():
		var lua_process = lua.pull_variant("Physics_process")

		lua.push_variant("Velocity", vec_to_arr(self.velocity))
		
		var player_pos = GameManager.player.position
		lua.push_variant("PlayerPosition", vec_to_arr(player_pos))
		lua.push_variant("Position", vec_to_arr(self.position))

		
		lua_process.call(delta)
		
		var velocity_lua = lua.pull_variant("Velocity")

		self.velocity = arr_to_vec(velocity_lua)

		move_and_slide()
	
	else:
		self.position = Vector3(100000, 0, 0)

var dead = false
