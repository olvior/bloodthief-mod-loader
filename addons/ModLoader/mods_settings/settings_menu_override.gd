extends "res://scripts/ui/settings_menu.gd"

var mods_button: Button
var mods_settings_scene_preload = preload("res://addons/ModLoader/mods_settings/mods_settings_scene.tscn")
var mods_settings_scene: Control
var back_button: Button

var button_preload = preload("res://addons/ModLoader/mods_settings/button_generic.tscn")
var mods_select_button_list: Array[Button] = []
var mods_select_list: Array = []
var current_mod_settings_scene: Control
var mod_scene_preload = preload("res://addons/ModLoader/mods_settings/generic_mod_settings_scene.tscn")

@onready var all_settings_scenes = [
	main_settings_screen_control,
	user_input_settings_screen,
	volume_settings_screen,
	user_input_settings_control,
	display_settings_screen,
	gameplay_settings_screen,
	$SettingsScreen,
]

var good_stylebox_hover
var good_stylebox_normal

func _ready():
	super._ready()
	create_mods_button()
	create_mods_settings_scene()
	link_mods_button()

func create_mods_button():
	var options_container = $SettingsScreen/MainContainer/PanelContainer/OptionsContainer
	mods_button = button_preload.instantiate()
	mods_button.text = "Mods"
	mods_button.name = "ModsSettingsButton"

	var random_button = options_container.get_child(2)
	good_stylebox_hover = random_button.get_theme_stylebox("hover")
	good_stylebox_normal = random_button.get_theme_stylebox("normal")

	mods_button.add_theme_stylebox_override("hover", good_stylebox_hover)
	mods_button.add_theme_stylebox_override("normal", good_stylebox_normal)


	options_container.add_child(mods_button)
	options_container.move_child(mods_button, 5)

func create_mods_settings_scene():
	mods_settings_scene = mods_settings_scene_preload.instantiate()
	mods_settings_scene.visible = false
	self.add_child(mods_settings_scene)

	back_button = mods_settings_scene.get_node("MarginContainer/MarginContainer/ScrollContainer/VBoxContainer/BackButton")
	back_button.pressed.connect(_on_mods_back_button_pressed)

	populate_mods_settings_scene()

func populate_mods_settings_scene():
	for mod_name in ModLoader.all_mods:
		var mod = ModLoader.all_mods[mod_name]
		ModLoader.debug_log("Setting up button for " + mod.name)
		if not mod.settings["settings_list"]:
			ModLoader.debug_log("Skipped " + mod.name)
			continue

		var settings_dict = mod.settings
		var settings_list = mod.settings["settings_list"]

		var new_button: Button = button_preload.instantiate()
		new_button.text = settings_dict["settings_page_name"]
		new_button.name = settings_dict["settings_page_name"] + "ModButton"
		new_button.add_theme_stylebox_override("hover", good_stylebox_hover)
		new_button.add_theme_stylebox_override("normal", good_stylebox_normal)

		var vbox_node: VBoxContainer = mods_settings_scene.get_node("MarginContainer/MarginContainer/ScrollContainer/VBoxContainer")
		vbox_node.add_child.call_deferred(new_button)
		vbox_node.move_child.call_deferred(new_button, 0)

		new_button.pressed.connect(_on_mod_scene_button_pressed.bind(mod))



func _on_mods_back_button_pressed():
	mods_settings_scene.visible = false
	display_main_settings_screen()

func link_mods_button():
	mods_button.pressed.connect(_on_mods_button_up)

func _on_mods_button_up():
	show_mods_settings_screen()

func show_mods_settings_screen():
	self.visible = true
	mods_settings_scene.visible = true
	for scene in all_settings_scenes:
		scene.visible = false


func _on_mod_scene_button_pressed(mod):
	ModLoader.debug_log("Pressed button for " + mod.name_pretty)

	for scene in all_settings_scenes:
		scene.visible = false
	mods_settings_scene.visible = false

	generate_settings_scene_for_mod(mod)

func generate_settings_scene_for_mod(mod):
	current_mod_settings_scene = mod_scene_preload.instantiate()
	current_mod_settings_scene.mod = mod
	current_mod_settings_scene.connect_to = _go_back_to_mods_scene
	self.add_child(current_mod_settings_scene)

	ModLoader.debug_log(current_mod_settings_scene)
	ModLoader.debug_log(current_mod_settings_scene.get_script())


func _go_back_to_mods_scene():
	current_mod_settings_scene.visible = false
	current_mod_settings_scene.queue_free()
	mods_settings_scene.visible = true

func _process(delta):
	super._process(delta)
	if visible and InputService.is_action_just_pressed("pause"):
		if mods_settings_scene.visible:
			_on_mods_back_button_pressed()
		if is_instance_valid(current_mod_settings_scene):
			if current_mod_settings_scene.visible:
				_go_back_to_mods_scene()
