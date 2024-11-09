extends Node

var lua



func _lua_print(message) -> void:
	print(message)

func _lua_play_sound(sound_path: String) -> void:
	if not sound_path.get_extension() in ["mp3", "wav", "ogg"]:
		print("ERROR: Invalid sound path ", sound_path)
		return

	var sound := load(sound_path)
	
	var new_audio_player := AudioStreamPlayer.new()
	self.add_child(new_audio_player)

	new_audio_player.stream = sound
	new_audio_player.play()
	new_audio_player.finished.connect(kill_audio_player.bind(new_audio_player))
	

func kill_audio_player(audio_player):
	audio_player.queue_free()

func gen_basic_lua_object():
	var lua_instance = ClassDB.instantiate("LuaAPI")
	
	# some functions it should have
	lua_instance.push_variant("print", _lua_print)
	lua_instance.push_variant("play_sound", _lua_play_sound)

	# All builtin libraries are available to bind with. Use OS and IO at your own risk.
	lua_instance.bind_libraries(["base", "table", "string"])

	return lua_instance


func _ready() -> void:
	lua = gen_basic_lua_object()


	var lua_str = FileAccess.get_file_as_string("res://addons/ModLoader/test.lua")

	var err = lua.do_string(lua_str)

	if err:
		printerr("ERROR %d: %s" % [err.type, err.message])
		return

	var val = lua.pull_variant("get_message")

	# we should check for an error but i dont know how to
	if false: #val:
		# printerr("ERROR %d: %s" % [val.type, val.message])
		# return
		pass

	var message = val.call([])
	print(message)

func _physics_process(delta):
	var lua_process = lua.pull_variant("Physics_process")

	lua_process.call(delta)

	var velocity_lua = lua.pull_variant("Velocity")

	self.velocity = velocity_lua
