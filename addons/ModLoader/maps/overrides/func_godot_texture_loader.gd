extends FuncGodotTextureLoader

func create_material(texture_name: String) -> Material:
	# Autoload material if it exists
	var material_dict: Dictionary = {}
	
	var material_path: String = "%s/%s.%s" % [map_settings.base_texture_dir, texture_name, map_settings.material_file_extension]
	if not material_path in material_dict:
		var loaded_material: Material = load(material_path)
		if loaded_material:
			material_dict[material_path] = loaded_material
		else:
			printerr("No material found: " + texture_name)
	
	
	# If material already exists, use it
	if material_path in material_dict:
		return material_dict[material_path]
	
	var material: Material = null
	
	if map_settings.default_material:
		material = map_settings.default_material.duplicate()
	else:
		material = StandardMaterial3D.new()
	var texture: Texture2D = load_texture(texture_name)
	if not texture:
		return material
	
	if material is BaseMaterial3D:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if map_settings.unshaded else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	
	if material is StandardMaterial3D:
		material.set_texture(StandardMaterial3D.TEXTURE_ALBEDO, texture)
	elif material is ShaderMaterial && map_settings.default_material_albedo_uniform != "":
		material.set_shader_parameter(map_settings.default_material_albedo_uniform, texture)
	elif material is ORMMaterial3D:
		material.set_texture(ORMMaterial3D.TEXTURE_ALBEDO, texture)
	
	var pbr_textures : Dictionary = get_pbr_textures(texture_name)
	
	for pbr_suffix in PBRSuffix.values():
		var suffix: int = pbr_suffix
		var tex: Texture2D = pbr_textures[suffix]
		if tex:
			if material is ShaderMaterial:
				material = StandardMaterial3D.new()
				material.set_texture(StandardMaterial3D.TEXTURE_ALBEDO, texture)
			var enable_prop: String = PBR_SUFFIX_PROPERTIES[suffix] if suffix in PBR_SUFFIX_PROPERTIES else ""
			if(enable_prop != ""):
				material.set(enable_prop, true)
			material.set_texture(PBR_SUFFIX_TEXTURES[suffix], tex)
		
	material_dict[material_path] = material
	
	if (map_settings.save_generated_materials and material 
		and texture_name != map_settings.clip_texture 
		and texture_name != map_settings.skip_texture 
		and texture.resource_path != "res://addons/func_godot/textures/default_texture.png"):
		ResourceSaver.save(material, material_path)
	
	return material
