extends Button

signal tile_info

var tag_scene: PackedScene = preload("res://prefabs/panel_cont_tag.tscn")
var poi_icon: CompressedTexture2D = preload("res://assets/icons/map/poi.png")

var data: MapTileData

func _ready() -> void:
	#name = TODO
	self_modulate = data.base_colour

func update_icon(new_size):
	if new_size >= 12.0 and new_size < 24.0:
		icon = poi_icon
		expand_icon = false
	elif new_size >= 24.0:
		icon = Shared.ICON_MAP[data.tile_type]
		expand_icon = true
	else:
		icon = null


func _on_pressed() -> void:
	tile_info.emit(data.coords)
