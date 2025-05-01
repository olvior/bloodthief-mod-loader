extends Node

var debug_file_path = OS.get_executable_path().get_base_dir() + "/debug.txt"
var debug = false

var all_textures = []

# Dictionary with {"namespace-name": mod_node}
var all_mods = {}

# Contains the class ModNode. Since the class is not present
# in the pck it has to be loaded in like this so that we can
# make nodes with is
var ModNode = preload("res://addons/ModLoader/mod_node.gd")

func _init():
	ProjectSettings.set_setting("application/config/version", ProjectSettings.get_setting("application/config/version") + " - Modded")

func _ready():
	if not FileAccess.file_exists(debug_file_path):
		var debug_file = FileAccess.open(debug_file_path, FileAccess.WRITE)
		debug_file.store_string("false")
		debug_file.close()
	debug = FileAccess.open(debug_file_path, FileAccess.READ).get_line() == "true"

	debug_log("starting")

	# This creates the needed log files and moves the old ones
	init_logs()

	# Searches though mods-unpacked/ to call `load_mod()` on the ones found
	start_loading_unpacked()

	# Searches through mods/ to load zips in and then call `load_mod()`
	start_loading_packed()

	# Overrites the original script with the custom one
	init_settings_menu()

	load_maps()

	var level_override_path = "res://addons/ModLoader/maps/level_select_screen.gd"
	var level_path = "res://scripts/ui/level_select/level_select_screen.gd"

	load(level_override_path).take_over_path(level_path)


	debug_log("finished")

###############
# MOD LOADING #
###############

func start_loading_unpacked():
	# open the mods folder
	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	var mods_folder = DirAccess.open(mods_folder_path)

	debug_log("Mods unpacked path: " + mods_folder_path)

	if not mods_folder:
		printerr("Failed to open mods-unpacked folder, make sure it exists")
		return


	debug_log("Searching through mods-unpacked/")

	# loop through it and add all nested folders into a list
	mods_folder.list_dir_begin()

	var file_name = mods_folder.get_next()
	var mod_folders = []

	while file_name != "":
		if mods_folder.current_is_dir():
			mod_folders.append(file_name)
		file_name = mods_folder.get_next()


	# loop over all the mod folders and add them in
	for mod_path in mod_folders:
		var _error = load_mod("%s/%s" % [mods_folder_path, mod_path], mod_path, mods_folder_path)

func start_loading_packed():
	# open the mods/ directory
	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods"
	var mods_packed_folder = DirAccess.open(mods_folder_path)

	debug_log()
	debug_log("Mods folder path: " + mods_folder_path)

	# make sure it exists
	if not mods_packed_folder:
		printerr("Failed to open mods folder, make sure it exists")
		return


	# loop through it to find zips
	mods_packed_folder.list_dir_begin()

	var file_name = mods_packed_folder.get_next()
	var mod_zips = []

	debug_log("Searching through mods/")
	while file_name != "":
		debug_log(file_name)
		if not file_name.substr(len(file_name) - 4, -1) == ".zip":
			file_name = mods_packed_folder.get_next()
			printerr("File is not a zip")
			continue

		mod_zips.append(file_name)
		debug_log(ProjectSettings.load_resource_pack("%s/%s" % [mods_folder_path, file_name]))
		debug_log("%s/%s" % [mods_folder_path, file_name])

		file_name = mods_packed_folder.get_next()

	for mod in mod_zips:
		var mod_name_wihout_zip = mod.substr(0, len(mod) - 4)
		debug_log(mod_name_wihout_zip)
		var _error = load_mod("res://" + mod.substr(0, len(mod) - 4), mod_name_wihout_zip, mods_folder_path)


func load_mod(mod_path, mod_name, mods_folder_path) -> Error:
	if mod_name in all_mods:
		return OK

	#var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"

	var current_mod = DirAccess.open(mod_path)

	# make sure the mod has a mod_main.gd
	if not current_mod.file_exists("mod_main.gd"):
		printerr("Failed to load %s, no mod_main.gd" % mod_name)
		return FAILED

	if not current_mod.file_exists("manifest.json"):
		printerr("Failed to load %s, no manifest.json" % mod_name)
		return FAILED

	# load it
	var current_script = load("%s/mod_main.gd" % mod_path)
	debug_log("%s/mod_main.gd" % mod_path)
	debug_log(current_script)



	# add it as a child
	var new_node = ModNode.new()
	new_node.set_script(current_script)

	# make sure it extends ModNode
	if new_node.get_class() != "ModNode":
		printerr("Failed to load %s, it does not extend ModNode, instead extends %s" % [mod_name, new_node.get_class()])
		new_node.queue_free()
		return FAILED

	# load manifest.json
	var manifest_json = "%s/manifest.json" % mod_path
	var manifest_text = FileAccess.get_file_as_string(manifest_json)
	var manifest_dict = JSON.parse_string(manifest_text)

	# check incompatabilites
	for mod in manifest_dict["incompatabilites"]:
		if mod in all_mods.keys():
			printerr("Failed to load %s, incompatable mod % is present" % [mod_name, mod])
			new_node.queue_free()
			return FAILED

	# load dependencies
	for mod in manifest_dict["dependencies"]:
		if mod not in all_mods.keys():
			debug_log("Loading dependencies")
			var error = load_mod("%s/%s" % [mods_folder_path, mod], mod, mods_folder_path)
			if error:
				printerr("Failed to load %s due to dependencies not loading" % mod_name)
				return FAILED

		new_node.dependencies[mod] = all_mods[mod]

	all_mods["%s-%s" % [manifest_dict["namespace"], manifest_dict["name"]]] = new_node



	new_node.name = "%s-%s" % [manifest_dict["namespace"], manifest_dict["name"]]
	new_node.name_space = manifest_dict["namespace"]
	new_node.name_without_namespace = manifest_dict["name"]

	new_node.name_pretty = manifest_dict["name_pretty"]

	new_node.path_to_dir = mod_path

	self.add_child(new_node)
	new_node.call("init")
	new_node.call("post_init")

	return OK


#############
# LOG STUFF #
#############

func init_logs():
	var logs_dir = DirAccess.open("user://logs")


	if logs_dir.file_exists("mod_loader.log"):
		var old_log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.READ)
		var date_and_time = old_log_file.get_line()

		logs_dir.rename("mod_loader.log", "mod_loader%s.log" % date_and_time)

	var log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.WRITE)

	log_file.store_line(Time.get_datetime_string_from_system())


func mod_log(text = ""):
	text = str(text)

	var log_path = "user://logs/mod_loader.log"
	var log_file = FileAccess.open(log_path, FileAccess.READ_WRITE)

	log_file.seek_end()

	log_file.store_line(text)
	log_file = null

	print(text)

func debug_log(message = ""):
	if debug:
		if message.strip_edges() == "":
			print(message)
		else:
			print("Mod Loader: %s" % message)



##################
# SETTINGS STUFF #
##################

func init_settings_menu():
	var settings_menu_script = load("res://addons/ModLoader/mods_settings/settings_menu_override.gd")
	settings_menu_script.take_over_path("res://scripts/ui/settings_menu.gd")

###############
# MAP LOADING #
###############

func load_maps():
	debug_log("\n")

	var maps_folder_path = OS.get_executable_path().get_base_dir() + "/maps"
	var maps_folder = DirAccess.open(maps_folder_path)

	debug_log("Maps path: " + maps_folder_path)

	if not maps_folder:
		debug_log("Failed to open maps/ folder, make sure it exists")
		return


	debug_log("Searching through maps/")

	# loop through it and add all nested folders into a list
	maps_folder.list_dir_begin()

	var file_name = maps_folder.get_next()
	var map_folders_list = []

	while file_name != "":
		if maps_folder.current_is_dir():
			if file_name == "disabled":
				file_name = maps_folder.get_next()
				continue
			map_folders_list.append(["%s/%s" % [maps_folder_path, file_name], file_name])

		file_name = maps_folder.get_next()

	for i in map_folders_list:
		debug_log(i)
		debug_log("Loading folder")
		load_map_folder(i[0], "", i[1])

		if DirAccess.dir_exists_absolute(i[0] + "/textures"):
			load_textures(i[0] + "/textures", "", i[1])


func load_textures(path_to_textures, extra_path, mod_name):
	var folder = DirAccess.open(path_to_textures + extra_path)
	debug_log("Opening for textures: %s" % path_to_textures + extra_path)

	if not folder:
		debug_log("Failed to open %s folder" % path_to_textures + extra_path)
		return

	folder.list_dir_begin()
	var file_name = folder.get_next()

	while file_name != "":
		if folder.current_is_dir():
			load_textures(path_to_textures, "%s/%s" % [extra_path, file_name], mod_name)
		else:
			if file_name.get_extension() == "png":
				# we load in the texture now that we found it
				var file_path = "%s/%s" % [path_to_textures + extra_path, file_name]
				var take_over_path = "res://textures/%s/%s" % [mod_name + extra_path, file_name]

				# create an image and a texture
				var image = Image.load_from_file(file_path)
				var tex: Texture2D = ImageTexture.create_from_image(image)

				# take over the other path, as func godot looks for textures
				# in res://textures
				tex.take_over_path(take_over_path)
				# enter the global scope or else the texture will get garbage collected (i think)
				all_textures.append(tex)

				debug_log("%s will take over" % tex)
				tex.take_over_path(take_over_path)
				debug_log(take_over_path)


		file_name = folder.get_next()


func load_map_folder(original_path, extra, mod_name):
	var path = original_path + extra
	var folder = DirAccess.open(path)

	debug_log("Opening: " + path)

	if not folder:
		debug_log("Failed to open %s folder" % path)
		return


	folder.list_dir_begin()
	var file_name = folder.get_next()

	while file_name != "":
		if folder.current_is_dir():
			load_map_folder(path, "/%s" + file_name, mod_name)
		else:
			if file_name.get_extension() == "map":
				var base_name = file_name.get_basename()

				var music_path = "%s/%s.mp3" % [path, base_name]
				var music_access = FileAccess.open(music_path, FileAccess.READ)
				if not music_access:
					music_path = null
					debug_log("No music found for %s/%s.map" % [path, base_name])

				var json_access = FileAccess.open("%s/%s.json" % [path, base_name], FileAccess.READ)
				if json_access:
					load_map(original_path, "%s/%s" % [path, base_name], mod_name, music_path)
				else:
					debug_log("Failed to open map %s/%s.json" % [path, base_name])


		file_name = folder.get_next()


	debug_log("\n")

class Map:
	var path: String
	var music_path: String
	var pack_path: String
	var mod_name: String

var map_by_index = {}

func load_map(original_path, path_without_extension: String, mod_name, music_path):
	var json_path = path_without_extension + ".json"
	var map_path = path_without_extension + ".map"
	debug_log(path_without_extension)

	var json_text = FileAccess.get_file_as_string(json_path)
	var map_json = JSON.parse_string(json_text)

	var new_config = LevelConfig.new()

	var level_index = len(GameManager.game_data.level_configs)

	new_config.level_name = map_json["level_name"]
	new_config.level_index = level_index

	new_config.display_name = map_json["display_name"]
	if len(map_json["medal_times"]) == 3:
		new_config.hex_medal_time_secs = map_json["medal_times"][0]
		new_config.blood_medal_time_secs = map_json["medal_times"][1]
		new_config.bone_medal_time_secs = map_json["medal_times"][2]

	else:
		new_config.god_killer_medal_time_secs = map_json["medal_times"][0]
		new_config.hex_medal_time_secs = map_json["medal_times"][1]
		new_config.blood_medal_time_secs = map_json["medal_times"][2]
		new_config.bone_medal_time_secs = map_json["medal_times"][3]


	new_config.is_automatically_unlocked = map_json["is_automatically_unlocked"]
	new_config.display_in_level_select = true

	debug_log(map_path)
	var new_map = Map.new()
	new_map.path = map_path
	new_map.music_path = music_path
	new_map.pack_path = original_path
	new_map.mod_name = mod_name

	map_by_index[level_index] = new_map

	new_config.scene_path = "res://addons/ModLoader/maps/map_level_loader.tscn"


	GameManager.game_data.level_configs.append(new_config)



var current_config: LevelConfig
var current_completion: LevelCompletionData

func set_next_level_config(level_config_and_completion: LevelConfigAndCompletionData):
	debug_log(level_config_and_completion)
	current_config = level_config_and_completion.config
	current_completion = level_config_and_completion.completion_data
	debug_log("Set level config to: %s" % level_config_and_completion.config.level_name)
