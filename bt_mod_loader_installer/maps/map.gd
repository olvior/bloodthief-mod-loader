extends MarginContainer

var manifest
var id: String
var my_path: String
var my_disabled_path: String
var is_installed: bool
var is_disabled: bool
@onready var main = Manager.main
@onready var debug_label: Label = main.current_tab_node.debug_label

@onready var install_button: Button = $VBoxContainer/HBoxContainer/install
@onready var uninstall_button: Button = $VBoxContainer/HBoxContainer/uninstall
@onready var disable_button: Button = $VBoxContainer/HBoxContainer/disable
@onready var enable_button: Button = $VBoxContainer/HBoxContainer/enable

@onready var name_label: Label = $VBoxContainer/name
@onready var author_label: Label = $VBoxContainer/authors
@onready var description_label: Label = $VBoxContainer/description

var enabled_list: Array[bool] = [true, false, false, true]
var disabled_list: Array[bool] = [true, false, true, false]
var uninstalled_list: Array[bool] = [false, true, true, true]

var no_format_check: bool = false


func check_if_installed():
	if not no_format_check:
		my_path = main.path + "/maps/" + id
		my_disabled_path = main.path + "/maps/disabled/" + id
	else:
		my_path = main.path + "/maps/" + manifest["name"]
		my_disabled_path = main.path + "/maps/disabled/" + manifest["name"]

	if DirAccess.dir_exists_absolute(my_path):
		is_installed = true
		change_buttons(enabled_list)

	elif DirAccess.dir_exists_absolute(my_disabled_path):
		is_disabled = true
		change_buttons(disabled_list)

	else:
		change_buttons(uninstalled_list)

	if not is_installed:
		$VBoxContainer/HBoxContainer/disable.disabled = true

		if not no_format_check:
			no_format_check = true
			check_if_installed()


func init(new_manifest):
	manifest = new_manifest
	id = manifest["namespace"] + "-" + manifest["name"]
	name_label.text = manifest["name_pretty"]
	description_label.text = manifest["description"]
	author_label.text = "Author(s): " + ", ".join(manifest.get("authors", []))

	check_if_installed()


func download(link: String, path: String):
	debug_label.text = "Downloading"
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _http_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		debug_label.text = "Request failed"
		push_error("Http request error")


func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		debug_label.text = "Download failed"
		push_error("Download Failed")
	else:
		var my_hash = main.hash_file(my_path + ".zip")
		if my_hash != manifest["SHA-256"]:
			print("Hashes do not match")
			print("Found: ", my_hash)
			print("Was given: ", manifest["SHA-256"])
			debug_label.text = "Hash does not match\nCanceled download"
			DirAccess.remove_absolute(my_path + ".zip")

			return

		print("Found: ", my_hash)
		print("All good")
		debug_label.text = "Downloaded"
		main.unzip(my_path + ".zip", main.path + "/maps")
		DirAccess.remove_absolute(my_path + ".zip")
		change_buttons(enabled_list)


func change_buttons(button_list: Array[bool]):
	install_button.disabled = button_list[0]
	uninstall_button.disabled = button_list[1]
	disable_button.disabled = button_list[2]
	enable_button.disabled = button_list[3]


func _on_install_button_up():
	download(manifest["download"], my_path + ".zip")


func _on_disable_button_up() -> void:
	DirAccess.rename_absolute(my_path, my_disabled_path)
	change_buttons(disabled_list)
	is_disabled = true
	debug_label.text = "Disabled mod"


func _on_enable_button_up() -> void:
	DirAccess.rename_absolute(my_disabled_path, my_path)
	change_buttons(enabled_list)
	is_disabled = false
	debug_label.text = "Enabled mod"


func _on_uninstall_button_up() -> void:
	if is_disabled:
		delete_folder_recursive(my_disabled_path)
	else:
		delete_folder_recursive(my_path)

	change_buttons(uninstalled_list)
	is_installed = false
	debug_label.text = "Uninstalled mod"


func delete_folder_recursive(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				delete_folder_recursive(path + "/" + file_name)
			else:
				DirAccess.remove_absolute(path + "/" + file_name)
			file_name = dir.get_next()

		DirAccess.remove_absolute(path)
	else:
		print("An error occurred when trying to access the path.")
