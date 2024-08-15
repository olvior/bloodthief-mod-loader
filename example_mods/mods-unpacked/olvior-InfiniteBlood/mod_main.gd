extends "res://addons/ModLoader/mod_node.gd"

func init():
	ModLoader.mod_log(name_pretty + " mod loaded")

func _process(_delta):
	if is_instance_valid(GameManager.player):
		GameManager.player.blood_amount = 6

