extends Control

@onready var back_button = $MarginContainer/MarginContainer/ScrollContainer/VBoxContainer/BackButton
@onready var vbox = $MarginContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var label = $MarginContainer/VBoxContainer/Label

var mod
var connect_to
var button_preload = preload("res://addons/ModLoader/mods_settings/button_generic.tscn")
var generic_setting = preload("res://addons/ModLoader/mods_settings/generic_setting.tscn")
var slider_preload = preload("res://addons/ModLoader/mods_settings/h_slider.tscn")

func _ready():
	label.text = mod.settings["settings_page_name"]
	print(back_button)
	print("huh setup")
	back_button.pressed.connect(connect_to)
	
	populate()


func populate():
	for setting in mod.settings["settings_list"]:
		var generic = create_setting_generic(setting)
		
		match setting.s_type:
			setting.SETTING_BOOL:
				create_setting_bool(generic, setting)
			setting.SETTING_INT:
				if setting.s_range:
					ModLoader.mod_log("Created int setting")
					create_slider(generic, setting, setting.s_range, true)
			setting.SETTING_FLOAT:
				if setting.s_range:
					ModLoader.mod_log("Created float setting")
					create_slider(generic, setting, setting.s_range, false)
			setting.SETTING_SELECTION:
				create_setting_selection(generic, setting)

func create_setting_generic(setting):
	var new_setting = generic_setting.instantiate()
	new_setting.get_node("Label").text = setting.s_name_pretty
	vbox.add_child(new_setting)
	vbox.move_child(new_setting, 0)
	
	return new_setting

func create_setting_bool(generic, setting):
	var new_check_box: CheckBox = load("res://addons/ModLoader/mods_settings/check_box.tscn").instantiate()
	new_check_box.button_pressed = setting.value
	generic.add_child(new_check_box)
	new_check_box.toggled.connect(_on_checkbox_toggled.bind(setting))

func _on_checkbox_toggled(on: bool, setting):
	setting.value = on

func create_slider(generic: HBoxContainer, setting, range: Vector2, round: bool):
	var new_slider: HSlider = slider_preload.instantiate()
	new_slider.min_value = range.x
	new_slider.max_value = range.y
	new_slider.step = 0.01
	new_slider.rounded = round
	new_slider.value = setting.value
	
	var new_label: Label = generic.get_node("Label2")
	new_label.text = str(new_slider.value)
	
	if len(new_label.text) == 1:
		new_label.text += "."
	while len(new_label.text) < 4:
		new_label.text += "0"
	
	new_label.name = "SliderLabel"

	generic.add_child(new_slider)
	generic.move_child(new_slider, 1)
	
	new_slider.value_changed.connect(_on_slider_value_changed.bind(setting, new_label))

func _on_slider_value_changed(value, setting, label):
	var value_str = str(value)
	if setting.s_type == setting.SETTING_FLOAT:
		if len(value_str) == 1:
			value_str += "."
		while len(value_str) < 4:
			value_str += "0"
	
	label.text = value_str
	setting.value = value

func create_setting_int(generic, setting):
	if setting.s_range:
		pass
	else:
		pass

func create_setting_float(generic, setting):
	pass

func create_setting_selection(generic, setting):
	pass
