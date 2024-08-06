extends Node

var all_mods = {}

func _ready():
	init_logs()
	
	mod_log("Starting up the mod loader")
	mod_log('')

	start_mod_loading()



func start_mod_loading():
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
		load_mod(mods_folder_path + "/" + mod_path, mod_path, mods_folder_path)
	
	mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods"
	var mods_packed_folder = DirAccess.open(OS.get_executable_path().get_base_dir() + "/mods")
	
	mod_log('')
	mod_log("Mods folder path: " + mods_folder_path)

	if not mods_packed_folder:
		mod_log("Failed to open mods folder, make sure it exists")
		return

	mods_packed_folder.list_dir_begin()

	file_name = mods_packed_folder.get_next()
	var mod_zips = []
	
	mod_log("Searching through mods/")
	while file_name != "":
		mod_log(file_name)
		mod_zips.append(file_name)
		mod_log(ProjectSettings.load_resource_pack(mods_folder_path + "/" + file_name))
		mod_log(mods_folder_path + "/" + file_name)

		file_name = mods_packed_folder.get_next()
		
	for mod in mod_zips:
		var mod_name_wihout_zip = mod.substr(0, len(mod) - 4) 
		mod_log(mod_name_wihout_zip)
		load_mod("res://" + mod.substr(0, len(mod) - 4), mod_name_wihout_zip, mods_folder_path)

	

	get_tree().get_root().print_tree_pretty()



func load_mod(mod_path, mod_name, mods_folder_path):
	if mod_name in all_mods:
		return

	#var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	
	var current_mod = DirAccess.open(mod_path)
	
	# make sure the mod has a mod_main.gd
	if not current_mod.file_exists("mod_main.gd"):
		mod_log("Failed to load " + mod_name + ", no mod_main.gd")
		return
	
	if not current_mod.file_exists("manifest.json"):
		mod_log("Failed to load " + mod_name + ", no manifest.json")
		return
	
	# load it
	var current_script = load(mod_path + "/mod_main.gd")
	mod_log(mod_path + "/mod_main.gd")
	mod_log(current_script)

	
	# add it as a child
	var new_node = Node.new()
	new_node.set_script(current_script)
	
	# make sure all mod_main.gd scripts have the init function
	if not new_node.has_method("init"):
		mod_log("Failed to load " + mod_path + ", no init function")
		new_node.queue_free()
		return


	# load manifest.json
	var manifest_json = mod_path + "/manifest.json"
	var manifest_text = FileAccess.get_file_as_string(manifest_json)
	var manifest_dict = JSON.parse_string(manifest_text)
	
	# check incompatabilites
	for mod in manifest_dict["incompatabilites"]:
		if mod in all_mods.keys():
			mod_log("Failed to load " + mod_name + ", incompatable mod " + mod + " is present")
			new_node.queue_free()
			return
	
	# load dependencies
	for mod in manifest_dict["dependencies"]:
		if mod not in all_mods.keys():
			mod_log("Loading dependencies")
			load_mod(mods_folder_path + "/" + mod, mod, mods_folder_path)

	all_mods[manifest_dict["namespace"] + "-" + manifest_dict["name"]] = new_node

	new_node.call("init")

	self.add_child(new_node)

	new_node.name = manifest_dict["name"]


func init_logs():
	var logs_dir = DirAccess.open("user://logs")
	
	
	if logs_dir.file_exists("mod_loader.log"):
		var old_log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.READ)
		var date_and_time = old_log_file.get_line()

		logs_dir.rename("mod_loader.log", "mod_loader" + date_and_time + ".log")

	var log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.WRITE)

	log_file.store_line(Time.get_datetime_string_from_system())


func mod_log(text, custom_path = ''):
	text = str(text)

	var log_path = "user://logs/mod_loader.log"
	var log_file = FileAccess.open("user://logs/mod_loader.log", FileAccess.READ_WRITE)
	
	log_file.seek_end()
	print(text, log_file, "help")

	log_file.store_line(text)
	log_file = null

	print(text)


