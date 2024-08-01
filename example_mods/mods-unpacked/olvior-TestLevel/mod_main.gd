extends Node


func init():
	print("Test level mod loaded")

func _ready():
	var level_helper = ModLoader.all_mods["olvior-LevelHelper"]
	level_helper.create_level("Supercoollevel", 1, "res://olvior-TestLevel/testroom.tscn", "Super cool level", "supercoollevelboard", [10, 20, 30], true)
