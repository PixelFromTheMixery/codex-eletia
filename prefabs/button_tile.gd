extends Button

signal tile_info

var tag_scene: PackedScene = preload("res://prefabs/panel_cont_tag.tscn")

var data: MapTileData

func _ready() -> void:
	#name = TODO
	self_modulate = data.base_colour
