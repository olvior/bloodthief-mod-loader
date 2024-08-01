extends MarginContainer

var manifest = {}

func init(new_manifest):
	manifest = new_manifest
	print(manifest)
	$VBoxContainer/name.text = manifest["name_pretty"]
	$VBoxContainer/description.text = manifest["description"]
