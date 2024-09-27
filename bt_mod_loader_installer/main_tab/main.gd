extends Control

@onready var tab_buttons: Array[Control] = [$Title/MarginContainer3/HBoxContainer/LoaderTab,
											$Title/MarginContainer3/HBoxContainer/ModsTab,
											$Title/MarginContainer3/HBoxContainer/MapsTab]
@onready var current_tab_node: Control = $Manager

var current_tab_index = 0
var main_nodes = [
					preload("res://main_tab/manager_scene.tscn"),
					preload("res://mods/mods_scene.tscn"),
					preload("res://maps/maps_scene.tscn"),
				]
var path

func set_button_theme_on(button: Button):
	button.add_theme_color_override("font_color", Color("ffffff"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("ffffff"))

func set_button_theme_off(button: Button):
	button.add_theme_color_override("font_color", Color("575757"))
	button.add_theme_color_override("font_hover_color", Color("575757"))
	button.add_theme_color_override("font_pressed_color", Color("575757"))

func _on_tab_button_down(index: int):
	if index == current_tab_index:
		# nothing needs to be done
		return
	
	# do themeing
	set_button_theme_off(tab_buttons[current_tab_index])
	set_button_theme_on(tab_buttons[index])
	
	# remove old instance
	current_tab_node.queue_free()
	
	# create instance
	current_tab_node = main_nodes[index].instantiate()
	current_tab_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.add_child(current_tab_node)
	
	current_tab_index = index


const CHUNK_SIZE = 1024
func hash_file(path):
	# Check that file exists.
	if not FileAccess.file_exists(path):
		return "NO"
	# Start an SHA-256 context.
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	# Open the file to hash.
	var file = FileAccess.open(path, FileAccess.READ)
	# Update the context after reading each chunk.
	while file.get_position() < file.get_length():
		var remaining = file.get_length() - file.get_position()
		ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
	# Get the computed hash.
	var res = ctx.finish()
	# Print the result as hex string and array.
	return res.hex_encode()
	printt(res.hex_encode(), Array(res))


func unzip(path_to_zip: String, path_to_unzipped: String) -> void:
	print("Unzipping " + path_to_zip + " to " + path_to_unzipped)
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
