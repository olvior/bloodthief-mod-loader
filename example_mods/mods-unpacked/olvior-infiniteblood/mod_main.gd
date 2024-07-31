extends Node

func init():
	print("inifiteblood loaded")


func _process(_delta):
	if is_instance_valid(GameManager.player):
		GameManager.player.blood_amount = 6

