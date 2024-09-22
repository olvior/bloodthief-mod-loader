extends Control

@onready var file_dialogue = $FileDialog
@onready var path_label = $Path/VBoxContainer/Path
@onready var error_label = $Label
@onready var main = get_parent()

func _on_open_file_dialogue_button_up():
	file_dialogue.show()

func _on_file_dialog_file_selected(new_path):
	var split = new_path.rsplit("/")
	var length = len(split[-1])
	main.path = new_path.substr(0, len(new_path) - length - 1)
	path_label.text = main.path

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
		main.path = probably_path
		path_label.text = main.path
	else:
		print("Failed")


func _on_remove__mod_loader_button_up():
	var folder = DirAccess.open(main.path)
	folder.rename("override.cfg", "nooverride.cfg")
	error_label.text = "Disabled the mod loader"
	

var n_of_downloads
var out_of
var loader_download_url = "https://github.com/olvior/bloodthief-mod-loader/releases/latest/download/mod_loader_maps_only.zip"
func _on_install_mod_loader_button_up():
	n_of_downloads = 0
	out_of = 0
	
	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	DirAccess.make_dir_absolute(main.path + "/mods")
	DirAccess.make_dir_absolute(main.path + "/mods/disabled")
	DirAccess.make_dir_absolute(main.path + "/mods-unpacked")
	download(loader_download_url, "user://mod_loader.zip")
	

func move_mod_loader():
	unzip("user://mod_loader.zip", main.path)

func unzip(path_to_zip: String, path_to_unzipped: String) -> void:
	var zr : ZIPReader = ZIPReader.new()
	
	if zr.open(path_to_zip) == OK:
		for filepath in zr.get_files():
			var zip_directory : String = path_to_zip.get_base_dir()
		
			var da : DirAccess = DirAccess.open(zip_directory)
			
			var extract_path : String = path_to_unzipped + '/'
			
			da.make_dir(extract_path)
			
			da = DirAccess.open(extract_path)
			print(da)
			
			da.make_dir_recursive(filepath.get_base_dir())
			
			print(extract_path + filepath)
			print(filepath, " is the path")
			
			var fa : FileAccess = FileAccess.open("%s/%s" % [extract_path, filepath], FileAccess.WRITE)
			if fa:
				fa.store_buffer(zr.read_file(filepath))


var http_s = []
func download(link, path):
	out_of += 1
	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	
	var http = HTTPRequest.new()
	add_child(http)
	http_s.append(http)
	http.connect("request_completed", _http_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	print("Downloading from " + link + " to " + path)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	
	n_of_downloads += 1
	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	
	if n_of_downloads == out_of:
		move_mod_loader()
