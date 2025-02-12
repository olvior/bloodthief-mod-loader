extends Control

var mods_dict :Dictionary= {}
var database_mods_dict :Dictionary= {}
var mod_scene :PackedScene= preload("res://mods/mod.tscn")

func _ready():
	scan_mod_folders()
	Manager.mods_scene = self

func scan_mod_folders():
	var mods_path :String= Manager.main.path + "/mods-unpacked"
	var mods_fallback_path :String= Manager.main.path + "/mods"

	mods_dict.clear()
	
	print("Scanning mod folders...")

	# Process both paths
	process_mod_directory(mods_path)
	process_mod_directory(mods_fallback_path)

	print("Finished scanning. Found mods: ", mods_dict.keys())

	populate_mods_list()

func process_mod_directory(directory_path):
	print("Checking directory:", directory_path)
	var dir = DirAccess.open(directory_path)

	if dir == null:
		print("Error: Unable to open directory -", directory_path)
		return

	if dir.list_dir_begin() != OK:
		print("Error: Failed to list directory contents -", directory_path)
		return

	var file_name :String= dir.get_next()
	while file_name != "":
		print("Found file/directory:", file_name)
		if dir.current_is_dir():
			var manifest_path = directory_path + "/" + file_name + "/manifest.json"
			print("Checking for manifest:", manifest_path)
			if FileAccess.file_exists(manifest_path):
				parse_manifest(manifest_path)
			else:
				print("No manifest found in", file_name)
		file_name = dir.get_next()
		

	dir.list_dir_end()

func parse_manifest(manifest_path):
	print("Parsing manifest:", manifest_path)
	var file :FileAccess= FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		print("Error: Failed to open manifest file:", manifest_path)
		return

	var content :String= file.get_as_text()
	var manifest_data :Variant= JSON.parse_string(content)

	if manifest_data == null:
		print("Error: Failed to parse JSON from:", manifest_path)
		return

	# Debug print mod info
	print("Loaded mod:", manifest_data.get("name_pretty", "Unknown"), "Namespace:", manifest_data["namespace"])

	mods_dict[manifest_data["namespace"] + "-" + manifest_data["name"]] = manifest_data

func clear_mods_list(getContainer) -> void:
	for i : Node in getContainer.get_children():
		i.queue_free()

func populate_mods_list():
	clear_mods_list($MarginContainer/ScrollContainer/VBoxContainer)
	
	print("Populating mod list...")
	for mod in mods_dict.values():
		add_mod_to_list(mod, $MarginContainer/ScrollContainer/VBoxContainer)

func add_mod_to_list(mod, getContainer, fromDatabase :bool= false):
	var new_mod_object :MarginContainer= mod_scene.instantiate()
	getContainer.add_child(new_mod_object)
	new_mod_object.call("init", mod, fromDatabase)
	print("Added mod to list:", mod.get("name_pretty", "Unknown"))

func _on_file_dialog_dir_selected(dir: String) -> void:
	var destination :String= Manager.main.path + "\\mods-unpacked"
	
	var dest :DirAccess= DirAccess.open(destination)
	
	if !dest.dir_exists(destination):
		dest.make_dir(destination)
	
	copy_directory(dir)
	scan_mod_folders()

func copy_directory(directory_path: String) -> void:
	var dir :DirAccess= DirAccess.open(directory_path)

	if dir == null:
		print("Error: Unable to open directory -", directory_path)
		return

	if dir.list_dir_begin() != OK:
		print("Error: Failed to list directory contents -", directory_path)
		return

	var destination_dir = Manager.main.path + "/mods-unpacked"
	

	var folder_name :String= directory_path.get_file()
	destination_dir += "/" + folder_name
	
	if !DirAccess.dir_exists_absolute(destination_dir):
		DirAccess.make_dir_absolute(destination_dir)
	
	var file_name :String= dir.get_next()
	while file_name != "":
		print("Found file/directory:", file_name)
		
		var source_path :String= directory_path + "/" + file_name
		var dest_path :String= destination_dir + "/" + file_name

		if dir.current_is_dir():
			if !DirAccess.dir_exists_absolute(dest_path):
				DirAccess.make_dir_absolute(dest_path)
			copy_directory(source_path)
		else:
			var error :Error= DirAccess.copy_absolute(source_path, dest_path)
			if error != OK:
				print("Error: Failed to copy file:", source_path, "to", dest_path)
			else:
				print("Copied file:", source_path, "to", dest_path)

		file_name = dir.get_next()

	dir.list_dir_end()

func _on_install_button_up() -> void:
	if Manager.settings["viewed_local_mod_warning"]:
		_on_accept_dialog_visibility_changed()
		return
	
	$AcceptDialog.visible = true

func _on_accept_dialog_visibility_changed() -> void:
	if $AcceptDialog.visible: return
	
	if !Manager.settings["viewed_local_mod_warning"]:
		Manager.settings["viewed_local_mod_warning"] = true
		Manager.save_config()
	
	$FileDialog.visible = true

func _on_open_mod_folder_button_up() -> void:
	OS.shell_open(Manager.main.path + "/mods")

func _on_open_unpacked_mods_folder_button_up() -> void:
	OS.shell_open(Manager.main.path + "/mods-unpacked")
