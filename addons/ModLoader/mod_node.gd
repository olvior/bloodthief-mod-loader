extends Node
class_name ModNode

var path_to_dir: String # path to the mod's directory

var name_space: String
var name_without_namespace: String

var name_pretty: String

var dependencies = {} # dict that holds the nodes

var save_file_path: String:
	get:
		return "user://mods/" + name_space + '-' + name_without_namespace + "/settings.json"

var save_file_folder: String:
	get:
		return "user://mods/" + name_space + '-' + name_without_namespace


var settings = {
	"settings_page_name" = name_pretty,
	"settings_list" = [

	]
}

func init():
	for i in settings["settings_list"]:
		print(i)
		print(i.load_value)
		print(i.load_value(i.s_name_pretty, i.value))
		i.value = i.load_value(i.s_name_pretty, i.value)

	ModLoader.mod_log(name + " mod loaded")

func get_class(): # overrides function to tell the class apart
	return "ModNode"

func add_input_event(action_name: StringName, keys: Array[Key], mouses: Array[MouseButton] = [], physical: bool = true, deadzone: float = 0.5) -> Error:
	if InputMap.has_action(action_name):
		#ModLoader.mod_log(name_pretty + " tried to add an input action that already exits!")
		return FAILED

	InputMap.add_action(action_name, deadzone)

	for key in keys:
		var new_event = InputEventKey.new()
		if physical:
			new_event.physical_keycode = key
		else:
			new_event.keycode = key

		InputMap.action_add_event(action_name, new_event)

	for mouse in mouses:
		var new_event = InputEventMouseButton.new()
		new_event.button_index = mouse

		InputMap.action_add_event(action_name, new_event)

	return OK


class Setting:
	var parent_class
	var s_name_pretty: String
	var s_type
	var s_selections: Array[String]
	var value:
		set(v):
			value = v
			self.save()
	var s_range

	enum {SETTING_INT, SETTING_FLOAT, SETTING_SELECTION, SETTING_BOOL, SETTING_TEXT_INPUT, SETTING_BUTTON}

	func _init(parent, setting_name_pretty: String, setting_type, default_value, number_range = Vector2(0, 0), selections: Array[String] = []):
		parent_class = parent
		s_name_pretty = setting_name_pretty
		s_type = setting_type
		s_range = number_range
		if s_type == SETTING_SELECTION:
			s_selections = selections

		value = default_value

	func load_value(setting_name: String, default_value):
		if self.s_type == SETTING_BUTTON:
			return default_value

		if not FileAccess.file_exists(self.parent_class.save_file_path):
			print("File does not exist")
			return default_value

		var data_string = FileAccess.get_file_as_string(self.parent_class.save_file_path)
		var data = JSON.parse_string(data_string)

		if data == null:
			print("Failed to load json string " + self.parent_class.name_pretty)
			return default_value

		if not setting_name in data.keys():
			print("Setting " + setting_name + " not in json " + self.parent_class.name_pretty)
			return default_value

		if data[setting_name] == null:
			print("Setting " + setting_name + " is null " + self.parent_class.name_pretty)
			return default_value

		return data[setting_name]

	func save():
		var file_path = self.parent_class.save_file_path

		var data = {}

		if FileAccess.file_exists(file_path):
			var data_string = FileAccess.get_file_as_string(file_path)
			data = JSON.parse_string(data_string)
		else:
			DirAccess.make_dir_recursive_absolute(self.parent_class.save_file_folder)

		data[self.s_name_pretty] = self.value

		var save_string = JSON.stringify(data, "	")

		var save_file = FileAccess.open(file_path, FileAccess.WRITE)
		save_file.store_string(save_string)

