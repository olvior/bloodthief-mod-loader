extends Control

@onready var file_dialogue = $FileDialog
@onready var path_label = $MarginContainer2/VBoxContainer/Path
@onready var error_label = $Label

var path = ""

func _on_open_file_dialogue_button_up():
	file_dialogue.show()

func _on_file_dialog_file_selected(path):
		path_label.text = path

func _ready():
	var probably_path = ""
	if OS.get_name() == "Windows":
		probably_path = "C:/Program Files (x86)/Steam/steamapps/common/Bloodthief Playtest"
		print("Windows")
	
	elif OS.get_name() == "Linux":
		probably_path = ".steam/steam/steamapps/common/Bloodthief Playtest"
		print("Linux")
		var data_dir = OS.get_data_dir() # ~/.local/share
		var data_dir_split = data_dir.rsplit("/") # ["", "home", "home", ".local", "share"]
		var home_dir = "/" + data_dir_split[1] + "/" + data_dir_split[2] + "/" # /home/home/
		probably_path = home_dir + probably_path
		
	
	var dir = DirAccess.open(probably_path)
	
	if dir:
		path = probably_path
		path_label.text = path
	
	else:
		print("Failed")


func _on_remove__mod_loader_button_up():
	var folder = DirAccess.open(path)
	folder.rename("override.cfg", "nooverride.cfg")
	error_label.text = "Disabled the mod loader"
	

var n_of_downloads = 0
var out_of = 0
func _on_install_mod_loader_button_up():
	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	download("https://raw.githubusercontent.com/olvior/bloodthief-mod-loader/main/override.cfg", path + "/override.cfg")
	DirAccess.make_dir_absolute(path + "/addons")
	DirAccess.make_dir_absolute(path + "/mods-unpacked")
	download("https://raw.githubusercontent.com/olvior/bloodthief-mod-loader/main/addons/mod_loader.gd", path + "/addons/mod_loader.gd")
	

var http_s = []
func download(link, path):
	out_of += 1
	
	var http = HTTPRequest.new()
	add_child(http)
	http_s.append(http)
	http.connect("request_completed", _http_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	
	n_of_downloads += 1
	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	
