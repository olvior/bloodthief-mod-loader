extends Node
class_name ModNode

var path_to_dir: String # path to the mod's directory

var _name: String
var name_space: String
var name_without_namespace: String

var name_pretty: String

var dependencies = {} # dict that holds the nodes

func init(): # should be overridden
	ModLoader.mod_log(name + " mod loaded")

func get_class():
	return "ModNode"


