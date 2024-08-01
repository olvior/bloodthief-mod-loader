extends Node

func init():
	print("Level Helper loaded")


func create_level(name, index, scene_path, display_name, leaderboard_name, medal_times, is_unlocked):
	var new_level_config = LevelConfig.new()
	new_level_config.level_name = name
	new_level_config.level_index = index
	new_level_config.scene_path = scene_path
	new_level_config.display_name = display_name
	new_level_config.leaderboard_name = leaderboard_name
	new_level_config.hex_medal_time_secs = medal_times[0]
	new_level_config.blood_medal_time_secs = medal_times[1]
	new_level_config.bone_medal_time_secs = medal_times[2]

	var new_level_completion_data = LevelCompletionData.new()
	new_level_completion_data.is_unlocked = is_unlocked

	GameManager._level_configs.append(new_level_config)

	GameManager.progress_data._level_completion_data[new_level_config.level_name] = new_level_completion_data

	load(scene_path)

