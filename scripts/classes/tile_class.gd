extends Node

class_name MapTileData

#ID
var coords: Array
var tile_id: String
var instance: int

#Fixed
var essence: String
var base_colour: Color
var tile_type: String
var poi: bool

#Dynamic
var discovered = false

func _init(world_ref: Array) -> void:
	var world_entry = World.tiles.get(world_ref)
	if world_entry == null:
		push_error("Tile ID %s not found in Library!" % world_ref)
		return
	self.coords = world_ref
	self.essence = world_entry["essence"]
	self.tile_type = world_entry["tile_type"]
	if self.tile_type in Shared.COLOUR_MAP.keys():
		self.base_colour = Shared.COLOUR_MAP[self.tile_type]	
	else:
		self.base_colour = Shared.COLOUR_MAP[self.essence]
	
	self.poi = world_entry["poi"]
