extends MarginContainer

var manifest
var id: String
var mod_path: String
var is_installed: bool

var debug_label: Label

@onready var main = Manager.main

@onready var install_button: Button = $VBoxContainer/HBoxContainer/install
@onready var uninstall_button: Button = $VBoxContainer/HBoxContainer/uninstall
@onready var disable_button: Button = $VBoxContainer/HBoxContainer/disable
@onready var enable_button: Button = $VBoxContainer/HBoxContainer/enable

@onready var name_label: Label = $VBoxContainer/name
#@onready var version_label: Label = $VBoxContainer/version
@onready var author_label: Label = $VBoxContainer/authors
#@onready var tags_label: Label = $VBoxContainer/tags
@onready var description_label: Label = $VBoxContainer/description

var from_database = true

var enabled_list: Array[bool] = [true, false, false, true]
var disabled_list: Array[bool] = [true, false, true, false]
var uninstalled_list: Array[bool] = [false, true, true, true]


func check_if_installed():
	mod_path = main.path + "/mods-unpacked/" + id

	if DirAccess.dir_exists_absolute(mod_path):
		is_installed = true
		change_buttons(enabled_list)
	elif DirAccess.dir_exists_absolute(mod_path + "_disabled"):
		change_buttons(disabled_list)


var my_path: String
var my_disabled_path: String
var is_disabled = false


func check_if_database_installed():
	my_path = main.path + "/mods/" + id + ".zip"
	my_disabled_path = main.path + "/mods/disabled/" + id + ".zip"

	if FileAccess.file_exists(my_path):
		is_installed = true
		change_buttons(enabled_list)

	elif FileAccess.file_exists(my_disabled_path):
		is_disabled = true
		change_buttons(disabled_list)

	else:
		change_buttons(uninstalled_list)

	if not is_installed:
		$VBoxContainer/HBoxContainer/disable.disabled = true


func init(new_manifest, fromDatabase: bool):
	from_database = fromDatabase
	manifest = new_manifest
	id = manifest["namespace"] + "-" + manifest["name"]

	# Display mod info
	name_label.text = manifest.get("name_pretty", "Unknown Mod")
#	version_label.text = "Version: " + manifest.get("version_number", "Unknown")
	author_label.text = "Author(s): " + ", ".join(manifest.get("authors", []))
	#tags_label.text = "Tags: " + ", ".join(manifest.get("tags", []))
	description_label.text = manifest.get("description_rich", "No description available.")

	if from_database:
		check_if_database_installed()
	else:
		check_if_installed()


func download(link: String, path: String):
	debug_label.text = "Downloading"
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _http_request_completed)
	printerr(path)
	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

	Manager.mods_scene.scan_mod_folders()


func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	else:
		var my_hash = main.hash_file(my_path)
		if my_hash != manifest["SHA-256"]:
			print("Hashes do not match")
			print("Found: ", my_hash)
			print("Was given: ", manifest["SHA-256"])
			debug_label.text = "Hash does not match\nCanceled download"
			DirAccess.remove_absolute(my_path)

			return

		debug_label.text = "Installed"
		check_if_database_installed()


func change_buttons(button_list: Array[bool]):
	install_button.disabled = button_list[0]
	uninstall_button.disabled = button_list[1]
	disable_button.disabled = button_list[2]
	enable_button.disabled = button_list[3]


func _on_install_button_up():
	download(manifest["download"], my_path)
	#Manager.mods_scene.populate_database_mods_list()


func _on_disable_button_up():
	if from_database:
		DirAccess.rename_absolute(my_path, my_disabled_path)

	else:
		DirAccess.rename_absolute(mod_path, mod_path + "_disabled")

	change_buttons(disabled_list)


func _on_enable_button_up():
	if from_database:
		DirAccess.rename_absolute(my_disabled_path, my_path)

	else:
		DirAccess.rename_absolute(mod_path + "_disabled", mod_path)

	change_buttons(enabled_list)


func _on_uninstall_button_up():
	print(my_path)
	if from_database:
		OS.move_to_trash(my_path)

	else:
		OS.move_to_trash(mod_path)
		Manager.mods_scene.populate_mods_list()
		(Manager.mods_scene.mods_dict as Dictionary).erase(id)

	change_buttons(uninstalled_list)
	is_installed = false
