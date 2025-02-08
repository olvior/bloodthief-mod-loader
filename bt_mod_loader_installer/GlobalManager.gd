extends Node

var main
var mods_scene

var cfg :ConfigFile= ConfigFile.new()

#Adding a dictionary incase if we need more settings
var settings = {
	viewed_local_mod_warning = false
}

func _ready() -> void:
	load_config()

func load_config() -> void:
	var err :Error= cfg.load("user://settings.cfg")
	
	if err != OK:
		printerr("Failed to Load Config, Error Code: " +  str(err))
		return
	
	for m_settings in cfg.get_sections():
		var m_vlmwarn :bool= cfg.get_value("Settings","viewed_local_mod_warning",settings["viewed_local_mod_warning"])
		
		settings["viewed_local_mod_warning"] = m_vlmwarn
		

func save_config() -> void:
	cfg.set_value("Settings","viewed_local_mod_warning",settings["viewed_local_mod_warning"])
	cfg.save("user://settings.cfg")
