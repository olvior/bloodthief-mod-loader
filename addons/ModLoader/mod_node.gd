extends Node
class_name ModNode

var path_to_dir: String # path to the mod's directory

var name_space: String
var name_without_namespace: String

var name_pretty: String

var dependencies = {} # dict that holds the nodes

var save_file_path: String:
	get:
		return "user://mods/%s-%s/settings.json" % [name_space, name_without_namespace]

var save_file_folder: String:
	get:
		return "user://mods/%s-%s" % [name_space, name_without_namespace]


var settings = {
	"settings_page_name" = name_pretty,
	"settings_list" = [

	]
}

func post_init():
	for setting in settings["settings_list"]:
		ModLoader.debug_log(setting)
		ModLoader.debug_log(setting.load_value)
		ModLoader.debug_log(setting.load_value(setting.s_name_pretty, setting.value))
		setting.value = setting.load_value(setting.s_name_pretty, setting.value)

	ModLoader.debug_log("%s mod loaded" % name_pretty)

func get_class(): # overrides function to tell the class apart
	return "ModNode"

func add_input_event(action_name: StringName, keys: Array[Key], mouses: Array[MouseButton] = [], physical: bool = true, deadzone: float = 0.5) -> Error:
	if InputMap.has_action(action_name):
		ModLoader.debug_log("%s tried to add an input action that already exits!" % name_pretty)
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
	var setting_data = {}
	var parent_class
	var s_name_pretty: String
	var s_type
	var s_selections: Array[String]
	var value:
		set(v):
			value = v
			self.save()
	var callback
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
		if self.s_type == SETTING_BUTTON:
			callback = default_value
			value = null

	func load_value(setting_name: String, default_value):
		if not FileAccess.file_exists(self.parent_class.save_file_path):
			printerr("File does not exist")
			return default_value

		var data_string = FileAccess.get_file_as_string(self.parent_class.save_file_path)
		var data = JSON.to_native(JSON.parse_string(data_string), true)

		if data == null:
			printerr("Failed to load json string")
			return default_value

		if not setting_name in data.keys():
			printerr("Setting %s not in json" % setting_name)
			return default_value

		if data[setting_name] == null:
			self.parent_class.ModLoader.debug_log("Setting %s is null" % setting_name)
			return default_value

		return data[setting_name]

	func save():
		if self.parent_class.name_space == "":
			self.parent_class.ModLoader.debug_log("ModNode name_space is null")
			return

		var file_path = self.parent_class.save_file_path

		var data = {}

		if FileAccess.file_exists(file_path):
			var data_string = FileAccess.get_file_as_string(file_path)
			data = JSON.to_native(JSON.parse_string(data_string), true)
		else:
			DirAccess.make_dir_recursive_absolute(self.parent_class.save_file_folder)

		data[self.s_name_pretty] = self.value

		var save_string = JSON.stringify(JSON.from_native(data, true), "\t")

		var save_file = FileAccess.open(file_path, FileAccess.WRITE)
		save_file.store_string(save_string)
