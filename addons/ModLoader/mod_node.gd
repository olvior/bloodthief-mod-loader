extends Node
class_name ModNode

var path_to_dir: String # path to the mod's directory

var name_space: String
var name_without_namespace: String

var name_pretty: String

var dependencies = {} # dict that holds the nodes

var settings = {
	"settings_page_name" = name_pretty,
	"settings_list" = [

	]
}

func init(): # should be overridden
	ModLoader.mod_log(name + " mod loaded")

func get_class(): # overrides function to tell the class apart
	return "ModNode"

func add_input_event(action_name: StringName, keys: Array[Key], mouses: Array[MouseButton] = [], physical: bool = true, deadzone: float = 0.5) -> Error:
	if InputMap.has_action(action_name):
		ModLoader.mod_log(name_pretty + " tried to add an input action that already exits!")
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
	var s_name_pretty: String
	var s_type
	var s_selections: Array[String]
	var value
	var s_range

	enum {SETTING_INT, SETTING_FLOAT, SETTING_SELECTION, SETTING_BOOL, SETTING_TEXT_INPUT}

	func _init(setting_name_pretty: String, setting_type, default_value, number_range = Vector2(0, 0), selections: Array[String] = []):
		s_name_pretty = setting_name_pretty
		s_type = setting_type
		s_range = number_range
		if s_type == SETTING_SELECTION:
			s_selections = selections

		value = default_value

