extends Node

var all_mods = []

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
		var current_mod = DirAccess.open(mods_folder_path + "/" + mod_path)
		
		# make sure the mod has a mod_main.gd
		if not current_mod.file_exists("mod_main.gd"):
			print("Failed to load " + mod_path + ", no mod_main.gd")
			continue
		
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
			continue

		new_node.call("init")

		self.add_child(new_node)
		all_mods.append(new_node)

		new_node.name = mod_path
	
	get_tree().get_root().print_tree_pretty()

var i = 0
func _process(_delta):
	i += 1
	if i == 5000:
		get_tree().get_root().print_tree_pretty()
		i = 0
