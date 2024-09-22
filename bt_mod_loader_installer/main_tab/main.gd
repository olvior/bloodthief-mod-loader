extends Control

@onready var loader_tab_button: Button = $Title/MarginContainer3/HBoxContainer/LoaderTab
@onready var mods_tab_button: Button = $Title/MarginContainer3/HBoxContainer/ModsTab

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
