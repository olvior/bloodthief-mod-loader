extends Node


func _ready():
	ProjectSettings.set_setting("application/config/version", ProjectSettings.get_setting("application/config/version") + " - Modded")
	
	load_maps()
	
	var level_override_path = "res://addons/ModLoader/maps/level_select_screen.gd"
	var level_path = "res://scripts/ui/level_select/level_select_screen.gd"
	
	load(level_override_path).take_over_path(level_path)
	
	get_tree().get_root().print_tree_pretty()

###############
# MAP LOADING #
###############

func load_maps():
	print("\n")
	
	var maps_folder_path = OS.get_executable_path().get_base_dir() + "/maps"
	var maps_folder = DirAccess.open(maps_folder_path)
	
	print("Maps path: " + maps_folder_path)
	
	if not maps_folder:
		print("Failed to open maps/ folder, make sure it exists")
		return
	
	
	print("Searching through maps/")
	
	# loop through it and add all nested folders into a list
	maps_folder.list_dir_begin()
	
	var file_name = maps_folder.get_next()
	var map_folders_list = []
	
	while file_name != "":
		if maps_folder.current_is_dir():
			map_folders_list.append(maps_folder_path + '/' + file_name)
		elif file_name.get_extension() == "zip":
			print("Added res://maps/" + file_name.get_basename())
			map_folders_list.append("res://maps/" + file_name.get_basename())
			ProjectSettings.load_resource_pack(maps_folder_path + '/' + file_name)
		
		file_name = maps_folder.get_next()
		
	for i in map_folders_list:
		print(i)
		print("Loading folder")
		load_map_folder(i)
	

func load_map_folder(path):
	var folder = DirAccess.open(path)
	
	print("Opening: " + path)
	
	if not folder:
		print("Failed to open " + path + " folder")
		return
	
	
	print("Searching through maps/")
	
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
					print("Failed to open map " + path + '/' + base_name + ".json")
			
		file_name = folder.get_next()
	
	for i in map_list:
		load_map(i)
	
	print("\n")

var map_file_by_index = {}

func load_map(path_without_extension: String):
	var json_path = path_without_extension + ".json"
	var map_path = path_without_extension + ".map"
	print(path_without_extension)
	
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
