extends Node

# Dictionary with {"namespace-name": mod_node}
var all_mods = {}

# Contains the class ModNode. Since the class is not present
# in the pck it has to be loaded in like this so that we can
# make nodes with is
var ModNode = preload("res://addons/ModLoader/mod_node.gd")

func _init():
	ProjectSettings.set_setting("application/config/version", ProjectSettings.get_setting("application/config/version") + " - Modded")

	# This creates the needed log files and moves the old ones
	init_logs()
	
	mod_log("Starting up the mod loader\n")
	
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

func _ready():
	get_tree().get_root().print_tree_pretty()
	

func start_loading_unpacked():
	# open the mods folder
	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	var mods_folder = DirAccess.open(mods_folder_path)
	
	mod_log("Mods unpacked path: " + mods_folder_path)
	
	if not mods_folder:
		mod_log("Failed to open mods-unpacked folder, make sure it exists")
		return
	
	
	mod_log("Searching through mods-unpacked/")
	
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
		var _error = load_mod(mods_folder_path + "/" + mod_path, mod_path, mods_folder_path)

func start_loading_packed():
	# open the mods/ directory
	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods"
	var mods_packed_folder = DirAccess.open(mods_folder_path)
	
	mod_log('')
	mod_log("Mods folder path: " + mods_folder_path)
	
	# make sure it exists
	if not mods_packed_folder:
		mod_log("Failed to open mods folder, make sure it exists")
		return
	
	
	# loop through it to find zips
	mods_packed_folder.list_dir_begin()
	
	var file_name = mods_packed_folder.get_next()
	var mod_zips = []
	
	mod_log("Searching through mods/")
	while file_name != "":
		mod_log(file_name)
		if not file_name.substr(len(file_name) - 4, -1) == ".zip":
			file_name = mods_packed_folder.get_next()
			mod_log("File is not a zip")
			continue
			
		mod_zips.append(file_name)
		mod_log(ProjectSettings.load_resource_pack(mods_folder_path + "/" + file_name))
		mod_log(mods_folder_path + "/" + file_name)
		
		file_name = mods_packed_folder.get_next()
		
	for mod in mod_zips:
		var mod_name_wihout_zip = mod.substr(0, len(mod) - 4) 
		mod_log(mod_name_wihout_zip)
		var _error = load_mod("res://" + mod.substr(0, len(mod) - 4), mod_name_wihout_zip, mods_folder_path)


func load_mod(mod_path, mod_name, mods_folder_path) -> Error:
	if mod_name in all_mods:
		return OK
	
	#var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	
	var current_mod = DirAccess.open(mod_path)
	
	# make sure the mod has a mod_main.gd
	if not current_mod.file_exists("mod_main.gd"):
		mod_log("Failed to load " + mod_name + ", no mod_main.gd")
		return FAILED
	
	if not current_mod.file_exists("manifest.json"):
		mod_log("Failed to load " + mod_name + ", no manifest.json")
		return FAILED
	
	# load it
	var current_script = load(mod_path + "/mod_main.gd")
	mod_log(mod_path + "/mod_main.gd")
	mod_log(current_script)
	
	
	
	# add it as a child
	var new_node = ModNode.new()
	new_node.set_script(current_script)
	
	# make sure it extends ModNode
	if new_node.get_class() != "ModNode":
		mod_log("Failed to load " + mod_path + ", it does not extend ModNode")
		mod_log("It extends " + new_node.get_class() + " instead")
		new_node.queue_free()
		return FAILED
	
	# load manifest.json
	var manifest_json = mod_path + "/manifest.json"
	var manifest_text = FileAccess.get_file_as_string(manifest_json)
	var manifest_dict = JSON.parse_string(manifest_text)
	
	# check incompatabilites
	for mod in manifest_dict["incompatabilites"]:
		if mod in all_mods.keys():
			mod_log("Failed to load " + mod_name + ", incompatable mod " + mod + " is present")
			new_node.queue_free()
			return FAILED
	
	# load dependencies
	for mod in manifest_dict["dependencies"]:
		if mod not in all_mods.keys():
			mod_log("Loading dependencies")
			var error = load_mod(mods_folder_path + "/" + mod, mod, mods_folder_path)
			if error:
				mod_log("Failed to load " + mod_name + " due to dependencies not loading")
				return FAILED
		
		new_node.dependencies[mod] = all_mods[mod]
	
	all_mods[manifest_dict["namespace"] + "-" + manifest_dict["name"]] = new_node
	
	
	
	new_node.name = manifest_dict["namespace"] + "-" + manifest_dict["name"]
	new_node.name_space = manifest_dict["namespace"]
	new_node.name_without_namespace = manifest_dict["name"]
	
	new_node.name_pretty = manifest_dict["name_pretty"]
	
	new_node.path_to_dir = mod_path
	
	self.add_child(new_node)
	new_node.call("init")
	
	return OK


#############
# LOG STUFF #
#############

func init_logs():
	var logs_dir = DirAccess.open("user://logs")
	
	
	if logs_dir.file_exists("mod_loader.log"):
		var old_log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.READ)
		var date_and_time = old_log_file.get_line()
		
		logs_dir.rename("mod_loader.log", "mod_loader" + date_and_time + ".log")
	
	var log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.WRITE)
	
	log_file.store_line(Time.get_datetime_string_from_system())


func mod_log(text):
	text = str(text)
	
	var log_path = "user://logs/mod_loader.log"
	var log_file = FileAccess.open(log_path, FileAccess.READ_WRITE)
	
	log_file.seek_end()
	
	log_file.store_line(text)
	log_file = null
	
	print(text)

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
	mod_log("\n")
	
	var maps_folder_path = OS.get_executable_path().get_base_dir() + "/maps"
	var maps_folder = DirAccess.open(maps_folder_path)
	
	mod_log("Maps path: " + maps_folder_path)
	
	if not maps_folder:
		mod_log("Failed to open maps/ folder, make sure it exists")
		return
	
	
	mod_log("Searching through maps/")
	
	# loop through it and add all nested folders into a list
	maps_folder.list_dir_begin()
	
	var file_name = maps_folder.get_next()
	var map_folders_list = []
	
	while file_name != "":
		if maps_folder.current_is_dir():
			map_folders_list.append(maps_folder_path + '/' + file_name)
		file_name = maps_folder.get_next()
		
	for i in map_folders_list:
		mod_log(i)
		mod_log("Loading folder")
		load_map_folder(i)
	

func load_map_folder(path):
	var folder = DirAccess.open(path)
	
	mod_log("Opening: " + path)
	
	if not folder:
		mod_log("Failed to open " + path + " folder")
		return
	
	
	mod_log("Searching through maps/")
	
	folder.list_dir_begin()
	
	var file_name = folder.get_next()
	var map_list = []
	
	while file_name != "":
		if folder.current_is_dir():
			pass
		else:
			if file_name.get_extension() == "map":
				var base_name = file_name.get_basename()
				var json_access = FileAccess.open(path + '/' + base_name + ".json", FileAccess.READ)
				if json_access:
					map_list.append(path + '/' + base_name)
				else:
					mod_log("Failed to open map " + path + '/' + base_name + ".json")
			
		file_name = folder.get_next()
	
	for i in map_list:
		load_map(i)
	
	mod_log("\n")

var map_file_by_index = {}

func load_map(path_without_extension: String):
	var json_path = path_without_extension + ".json"
	var map_path = path_without_extension + ".map"
	mod_log(path_without_extension)
	
	var json_text = FileAccess.get_file_as_string(json_path)
	var map_json = JSON.parse_string(json_text)
	
	var new_config = LevelConfig.new()
	
	var level_index = len(GameManager._level_configs) + 1
	
	new_config.level_name = map_json["level_name"]
	new_config.level_index = level_index
	
	new_config.display_name = map_json["display_name"]
	new_config.hex_medal_time_secs = map_json["medal_times"][0]
	new_config.blood_medal_time_secs = map_json["medal_times"][1]
	new_config.bone_medal_time_secs = map_json["medal_times"][2]
	
	new_config.is_automatically_unlocked = map_json["is_automatically_unlocked"]
	
	print(map_path)
	map_file_by_index[level_index] = map_path
	
	new_config.scene_path = 'res://addons/ModLoader/maps/map_level_loader.tscn'
	
	GameManager._level_configs.append(new_config)


var current_config: LevelConfig
var current_completion: LevelCompletionData

func set_next_level_config(level_config_and_completion: LevelConfigAndCompletionData):
	print(level_config_and_completion)
	current_config = level_config_and_completion.config
	current_completion = level_config_and_completion.completion_data
	print("SET LEVEL CONFIG TO", level_config_and_completion.config.level_name)
