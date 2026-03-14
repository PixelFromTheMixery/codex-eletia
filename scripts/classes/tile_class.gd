extends Node

class_name MapTileData

#ID
var coords: Array
var tile_id: String

#Fixed
var essence: String
var base_colour: Color
var tile_type: String
var poi: bool

#Dynamic
var discovered = false

func _init(world_ref: Array) -> void:
	var world_entry = World.tiles[world_ref]
	self.coords = world_ref
	self.essence = world_entry["essence"]
	self.tile_type = world_entry["tile_type"]
	if self.tile_type in Shared.COLOUR_MAP.keys():
		self.base_colour = Shared.COLOUR_MAP[self.tile_type]	
	else:
		self.base_colour = Shared.COLOUR_MAP[self.essence]
	
	self.poi = world_entry["poi"]
