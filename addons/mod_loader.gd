extends Node

var all_mods = {}

func _ready():
	print("Starting up the mod loader")
	# open the mods folder
	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	print(mods_folder_path)
	var mods_folder = DirAccess.open(mods_folder_path)
	print(mods_folder)
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
		load_mod(mod_path)

	get_tree().get_root().print_tree_pretty()



func load_mod(mod_path):
	if mod_path in all_mods:
		return

	var mods_folder_path = OS.get_executable_path().get_base_dir() + "/mods-unpacked"
	
	var current_mod = DirAccess.open(mods_folder_path + "/" + mod_path)
	
	# make sure the mod has a mod_main.gd
	if not current_mod.file_exists("mod_main.gd"):
		print("Failed to load " + mod_path + ", no mod_main.gd")
		return
	
	if not current_mod.file_exists("manifest.json"):
		print("Failed to load " + mod_path + ", no manifest.json")
		return
	
	# load it
	var current_script = load(mods_folder_path + "/" + mod_path + "/mod_main.gd")
	print(current_script)

	
	# add it as a child
	var new_node = Node.new()
	new_node.set_script(current_script)
	
	# make sure all mod_main.gd scripts have the init function
	if not new_node.has_method("init"):
		print("Failed to load " + mod_path + ", no init function")
		new_node.queue_free()
		return


	# load manifest.json
	var manifest_json = mods_folder_path + "/" + mod_path + "/manifest.json"
	var manifest_text = FileAccess.get_file_as_string(manifest_json)
	var manifest_dict = JSON.parse_string(manifest_text)
	
	# check incompatabilites
	for mod in manifest_dict["extra"]["godot"]["incompatabilites"]:
		if mod in all_mods.keys():
			print("Failed to load " + mod_path + ", incompatable mod " + mod + " is present")
			new_node.queue_free()
			return
	
	# load dependencies
	for mod in manifest_dict["dependencies"]:
		if mod not in all_mods.keys():
			print("Loading dependencies")
			load_mod(mod)

	all_mods[manifest_dict["namespace"] + "-" + manifest_dict["name"]] = new_node

	new_node.call("init")

	self.add_child(new_node)

	new_node.name = manifest_dict["name"]

