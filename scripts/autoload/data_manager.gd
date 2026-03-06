extends Node

const data_path: String = "res://data/"

var actions: Dictionary
var items: Dictionary
var upgrades: Dictionary

func _ready() -> void:
	load_game_data()

func load_game_data():
	"""Maps load data into local variables"""
	for key in ["actions", "items", "upgrades"]:
		set(key, JSON.parse_string(FileAccess.get_file_as_string("%s%s.json" % [data_path,key])))
