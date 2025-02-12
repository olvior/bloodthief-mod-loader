extends Control

var mods_dict: Dictionary= {}
var database_mods_dict: Dictionary= {}
var mod_scene: PackedScene= preload("res://mods/mod.tscn")

@onready var list_node = $MarginContainer/ScrollContainer/VBoxContainer

func _ready():
	scan_mod_folders()
	get_data("https://raw.githubusercontent.com/olvior/bloodthief-mod-list/main/list.json")
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

func populate_database_mods_list():
	print("Populating database mod list...")
	for mod in database_mods_dict.values():
		add_mod_to_list(mod, list_node, true)

func add_mod_to_list(mod, getContainer, fromDatabase :bool= false):
	var new_mod_object :MarginContainer= mod_scene.instantiate()
	getContainer.add_child(new_mod_object)
	new_mod_object.call("init", mod, fromDatabase)
	print("Added mod to list:", mod.get("name_pretty", "Unknown"))


func get_data(link):
	print("Downloading")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _http_request_completed)
	
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, body):
	if result != OK:
		push_error("Download Failed")
		return
	
	database_mods_dict = JSON.parse_string(body.get_string_from_utf8())
	populate_database_mods_list()
	print("Downloaded")


func _on_open_mod_folder_button_up() -> void:
	OS.shell_open(Manager.main.path + "/mods")
