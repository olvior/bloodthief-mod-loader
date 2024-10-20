extends FuncGodotMap

func init_texture_loader() -> FuncGodotTextureLoader:
	# this is where we take control
	return load("res://addons/ModLoader/maps/overrides/func_godot_texture_loader.gd").new(map_settings)
