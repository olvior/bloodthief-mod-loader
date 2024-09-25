extends MarginContainer

var manifest
var id: String
var my_path: String
var my_disabled_path: String
var is_installed: bool
var is_disabled: bool
@onready var main = get_tree().get_root().get_child(0)
@onready var debug_label: Label = main.current_tab_node.debug_label

@onready var install_button: Button = $VBoxContainer/HBoxContainer/install
@onready var uninstall_button: Button = $VBoxContainer/HBoxContainer/uninstall
@onready var disable_button: Button = $VBoxContainer/HBoxContainer/disable
@onready var enable_button: Button = $VBoxContainer/HBoxContainer/enable

var enabled_list: Array[bool] = [true, false, false, true]
var disabled_list: Array[bool] = [true, false, true, false]
var uninstalled_list: Array[bool] = [false, true, true, true]

func check_if_installed():
	my_path = main.path + "/maps/" + id
	my_disabled_path = main.path + "/maps/disabled/" + id
	
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
	

func init(new_manifest):
	manifest = new_manifest
	id = manifest["namespace"] + "-" + manifest["name"]
	$VBoxContainer/name.text = manifest["name_pretty"]
	$VBoxContainer/description.text = manifest["description"]
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
		DirAccess.remove_absolute(my_disabled_path)
	else:
		DirAccess.remove_absolute(my_path)
	
	change_buttons(uninstalled_list)
	is_installed = false
	debug_label.text = "Uninstalled mod"
