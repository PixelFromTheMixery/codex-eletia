extends Node

class_name MapTileData

#ID
var coords: Array
var tile_id: String

#Fixed
var essence: String
var base_colour: Color

#Dynamic
var discovered = false

func _init(world_ref: Array) -> void:
	var world_entry = World.tiles[world_ref]
	self.coords = world_ref
	self.essence = world_entry["essence"]
	self.base_colour = Shared.COLOUR_MAP[self.essence]
