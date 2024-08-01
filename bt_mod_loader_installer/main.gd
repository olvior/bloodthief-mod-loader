extends Control

@onready var loader_tab_button = $Title/MarginContainer3/HBoxContainer/LoaderTab
@onready var mods_tab_button = $Title/MarginContainer3/HBoxContainer/ModsTab
@onready var current_tab_main_node = $Manager

var current_tab = 0
var main_nodes = [preload("res://manager_scene.tscn"), preload("res://mods_scene.tscn")]
var path

func _on_loader_tab_button_down():
	loader_tab_button.add_theme_color_override("font_color", Color("ffffff"))
	mods_tab_button.add_theme_color_override("font_color", Color("575757"))
	loader_tab_button.add_theme_color_override("font_hover_color", Color("ffffff"))
	mods_tab_button.add_theme_color_override("font_hover_color", Color("575757"))
	loader_tab_button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	mods_tab_button.add_theme_color_override("font_pressed_color", Color("575757"))
	
	if current_tab != 0:
		current_tab_main_node.queue_free()
		current_tab = 0
		current_tab_main_node = main_nodes[0].instantiate()
		self.add_child(current_tab_main_node)
		current_tab_main_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		

func _on_mods_tab_button_down():
	loader_tab_button.add_theme_color_override("font_color", Color("575757"))
	mods_tab_button.add_theme_color_override("font_color", Color("ffffff"))
	loader_tab_button.add_theme_color_override("font_hover_color", Color("575757"))
	mods_tab_button.add_theme_color_override("font_hover_color", Color("ffffff"))
	loader_tab_button.add_theme_color_override("font_pressed_color", Color("575757"))
	mods_tab_button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	
	if current_tab != 1:
		current_tab_main_node.queue_free()
		current_tab = 1
		current_tab_main_node = main_nodes[1].instantiate()
		self.add_child(current_tab_main_node)
		current_tab_main_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		

