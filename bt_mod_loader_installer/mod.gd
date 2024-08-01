extends MarginContainer

var manifest
var id
var my_path
var is_installed
@onready var main = get_tree().get_root().get_child(0)

func check_if_installed():
	var mods_folder = DirAccess.open(main.path + "/mods")
	my_path = main.path + "/mods/" + id
	if DirAccess.dir_exists_absolute(my_path):
		is_installed = true
	
	if is_installed:
		$VBoxContainer/HBoxContainer/install.text = "Reinstall"

func init(new_manifest):
	manifest = new_manifest
	id = manifest["namespace"] + "-" + manifest["name"]
	$VBoxContainer/name.text = manifest["name_pretty"]
	$VBoxContainer/description.text = manifest["description"]
	check_if_installed()


func _on_install_button_up():
	download(manifest["download"], my_path + ".zip")


func download(link, path):
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _http_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	
	
