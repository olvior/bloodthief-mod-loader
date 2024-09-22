extends Control

var maps_dict
var map_scene = preload("res://maps/map.tscn")
@onready var debug_label: Label = $DebugLabel

func _ready():
	get_data("https://raw.githubusercontent.com/olvior/bloodthief-mod-list/main/map_list.json")

func populate_maps_list():
	for map in maps_dict.values():
		add_map_to_list(map)

func add_map_to_list(map):
	var new_map_object = map_scene.instantiate()
	$MarginContainer/ScrollContainer/VBoxContainer.add_child(new_map_object)
	new_map_object.call("init", map)


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
		return
	
	maps_dict = JSON.parse_string(body.get_string_from_utf8())
	populate_maps_list()
	print("Downloaded")
	
