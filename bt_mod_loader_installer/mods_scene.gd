extends Control

var mods_dict
var mod_scene = preload("res://mod.tscn")

func _ready():
	get_data("https://raw.githubusercontent.com/olvior/bloodthief-mod-list/main/list.json")

func populate_mods_list():
	for mod in mods_dict.values():
		add_mod_to_list(mod)

func add_mod_to_list(mod):
	var new_mod_object = mod_scene.instantiate()
	$MarginContainer/ScrollContainer/VBoxContainer.add_child(new_mod_object)
	new_mod_object.call("init", mod)


func get_data(link):
	print("Downloading")
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", _http_request_completed)
	
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, body):
	if result != OK:
		push_error("Download Failed")
	
	mods_dict = JSON.parse_string(body.get_string_from_utf8())
	populate_mods_list()
	print("Downloaded")
	
