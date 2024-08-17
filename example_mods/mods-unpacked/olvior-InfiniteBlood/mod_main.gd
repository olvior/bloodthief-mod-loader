extends "res://addons/ModLoader/mod_node.gd"

var blood_setting = Setting.new("Blood Amount", Setting.SETTING_FLOAT, Vector2(0, 6))


func init():
	ModLoader.mod_log(name_pretty + " mod loaded")
	
	settings = {
		"settings_page_name" = "Infinite Blood",
		"settings_list" = [
			blood_setting
		]
	}

func _process(_delta):
	if is_instance_valid(GameManager.player):
		if GameManager.player.blood_amount < blood_setting.value:
			GameManager.player.blood_amount = blood_setting.value
		
