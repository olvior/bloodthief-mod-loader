extends Control

@onready var file_dialogue = $FileDialog
@onready var path_label = $Path/VBoxContainer/Path
@onready var error_label = $Label
@onready var main = get_parent()

@onready var disable_button = $"Manage mod loader/HBoxContainer/VBoxContainer/remove_ mod_loader"
@onready var enable_button = $"Manage mod loader/HBoxContainer/VBoxContainer/enable_ mod_loader"


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
		probably_path = "C:/Program Files (x86)/Steam/steamapps/common/Bloodthief Demo"
		print("Windows")

	elif OS.get_name() == "Linux":
		probably_path = ".steam/steam/steamapps/common/Bloodthief Demo"
		print("Linux")
		var data_dir = OS.get_data_dir()  # ~/.local/share
		var data_dir_split = data_dir.rsplit("/")  # ["", "home", "home", ".local", "share"]
		var home_dir = "/" + data_dir_split[1] + "/" + data_dir_split[2] + "/"  # /home/home/
		probably_path = home_dir + probably_path
	$load_game_console.disabled = true
	$load_game_console.tooltip_text = "Disabled for now"

	var dir = DirAccess.open(probably_path)

	if dir:
		main.path = probably_path
		path_label.text = main.path
	else:
		print("Failed")

	if FileAccess.file_exists(main.path + "/override.cfg"):
		enable_button.disabled = true
		disable_button.disabled = false
	else:
		enable_button.disabled = false
		disable_button.disabled = true

		if !FileAccess.file_exists(main.path + "/nooverride.cfg"):
			enable_button.disabled = true
			disable_button.disabled = true


func _on_enable__mod_loader_button_up() -> void:
	var folder = DirAccess.open(main.path)
	folder.rename("nooverride.cfg", "override.cfg")
	error_label.text = "Enabled the mod loader"
	enable_button.disabled = true
	disable_button.disabled = false


func _on_remove__mod_loader_button_up():
	var folder = DirAccess.open(main.path)
	folder.rename("override.cfg", "nooverride.cfg")
	error_label.text = "Disabled the mod loader"
	enable_button.disabled = false
	disable_button.disabled = true


var n_of_downloads
var out_of
var loader_download_url = "https://github.com/olvior/bloodthief-mod-loader/releases/latest/download/mod_loader.zip"


func _on_install_mod_loader_button_up():
	n_of_downloads = 0
	out_of = 0

	error_label.text = "Downloaded " + str(n_of_downloads) + "/" + str(out_of)
	DirAccess.make_dir_absolute(main.path + "/mods")
	DirAccess.make_dir_absolute(main.path + "/mods/disabled")
	DirAccess.make_dir_absolute(main.path + "/maps")
	DirAccess.make_dir_absolute(main.path + "/maps/disabled")
	DirAccess.make_dir_absolute(main.path + "/mods-unpacked")
	download(loader_download_url, "user://mod_loader.zip")
	enable_button.disabled = false
	disable_button.disabled = true


func move_mod_loader():
	main.unzip("user://mod_loader.zip", main.path)


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


func _on_file_dialog_dir_selected(dir: String) -> void:
	main.path = dir
	path_label.text = main.path


func _on_load_game_button_up() -> void:
	error_label.text = "Launching Bloodthief..."

	var error_code: Error = OS.shell_open("steam://run/2941730")

	if error_code != -1:
		error_label.text = "Bloodthief Running"
	else:
		error_label.text = "Something went wrong. \nError Code: " + str(error_code)


var terminal_paths = [
	"x-terminal-emulator",
	"gnome-terminal",
	"konsole",
	"xfce4-terminal",
	"alacritty",
	"lxterminal",
	"mate-terminal",
	"terminator",
	"urxvt",
	"rxvt"
]


func _on_load_game_console_button_up() -> void:
	error_label.text = "Launching Bloodthief..."
	var error_code

	print(OS.get_name())

	if OS.get_name().contains("Windows"):
		error_code = OS.execute(
			"cmd.exe", ["-c", main.path + "/bloodthief.console"], [], true, true
		)
	elif OS.get_name().contains("Linux") || OS.get_name().contains("BSD"):
		for terminal in terminal_paths:
			error_code = OS.execute("bash", ["-c", "steam steam://rungameid/2941730"])
			if error_code == OK:
				break  # Stop after the first successful launch

	print(error_code)

	if error_code != -1:
		error_label.text = "Bloodthief Running"
	else:
		error_label.text = "Something went wrong. \nError Code: " + str(error_code)
