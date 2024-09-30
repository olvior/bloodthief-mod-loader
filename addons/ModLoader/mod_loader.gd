extends Node

func _init():
	ProjectSettings.set_setting("application/config/version", ProjectSettings.get_setting("application/config/version") + " - Modded")

func _ready():
	print("MOD LOADER starting\n\n")
	
	load_maps()
	
	var level_override_path = "res://addons/ModLoader/maps/level_select_screen.gd"
	var level_path = "res://scripts/ui/level_select/level_select_screen.gd"
	
	load(level_override_path).take_over_path(level_path)

	print("MOD LOADER finished\n\n")

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
			if file_name == "disabled":
				file_name = maps_folder.get_next()
				continue
			map_folders_list.append([maps_folder_path + '/' + file_name, file_name])
			
		file_name = maps_folder.get_next()
		
	for i in map_folders_list:
		print(i)
		print("Loading folder")
		load_map_folder(i[0])
		
		if DirAccess.dir_exists_absolute(i[0] + '/textures'):
			load_textures(i[0] + '/textures', '', i[1])
		
		if DirAccess.dir_exists_absolute(i[0] + '/fgd'):
			load_fgd(i[0] + '/fgd')
		
	

func load_textures(path_to_textures, extra_path, mod_name):
	var folder = DirAccess.open(path_to_textures + extra_path)
	print("Opening for textures: " + path_to_textures + extra_path)
	
	if not folder:
		print("Failed to open " + path_to_textures + extra_path + " folder")
		return
	
	folder.list_dir_begin()
	var file_name = folder.get_next()
	
	while file_name != "":
		if folder.current_is_dir():
			load_textures(path_to_textures, extra_path + '/' + file_name, mod_name)
		else:
			if file_name.get_extension() == "png":
				var file_path = path_to_textures + extra_path + '/' + file_name
				var take_over_path = "res://textures/" + mod_name + extra_path + '/' + file_name
				var img = Image.new()
				var err = img.load(file_path)
				if err != OK:
					file_name = folder.get_next()
					continue
				
				
				var newTexture = ImageTexture.create_from_image(img)
				var thing = newTexture.create_placeholder()
				
				thing.take_over_path(take_over_path)
				
				print(file_path)
				print("takes over")
				print(take_over_path)
				
		file_name = folder.get_next()


func load_map_folder(path):
	var folder = DirAccess.open(path)
	
	print("Opening: " + path)
	
	if not folder:
		print("Failed to open " + path + " folder")
		return
	
		
	folder.list_dir_begin()
	var file_name = folder.get_next()
	
	while file_name != "":
		if folder.current_is_dir():
			load_map_folder(path + '/' + file_name)
		else:
			if file_name.get_extension() == "map":
				var base_name = file_name.get_basename()
				var json_access = FileAccess.open(path + '/' + base_name + ".json", FileAccess.READ)
				if json_access:
					load_map(path + '/' + base_name)
				else:
					print("Failed to open map " + path + '/' + base_name + ".json")
			
		file_name = folder.get_next()
	
	
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

var fgd_paths: Array[String] = []

func load_fgd(path):
	var folder = DirAccess.open(path)
	print("Opening for fdg: " + path)
	
	if not folder:
		print("Failed to open " + path + " folder")
		return
	
	folder.list_dir_begin()
	var file_name = folder.get_next()
	
	while file_name != "":
		if folder.current_is_dir():
			load_fgd(path + '/' + file_name)
		else:
			if file_name.get_extension() == "tres":
				fgd_paths.append(path + '/' + file_name)
				print("Adding " + file_name + " to fgd list")
			
		file_name = folder.get_next()

var current_config: LevelConfig
var current_completion: LevelCompletionData

func set_next_level_config(level_config_and_completion: LevelConfigAndCompletionData):
	print(level_config_and_completion)
	current_config = level_config_and_completion.config
	current_completion = level_config_and_completion.completion_data
	print("SET LEVEL CONFIG TO", level_config_and_completion.config.level_name)
