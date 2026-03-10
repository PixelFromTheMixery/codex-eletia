extends Node

class_name MapGenerator


var colour_map: Dictionary[String, Color] = {
	
}

var chunk_size: int
var full_size: int

var world_tiles: Dictionary[Array, Dictionary]

func recreate_world(grid_map):
	reset_world(grid_map)
	generate_basic_grid()
	World.tiles = world_tiles
	Save.save_world()

func reset_world(grid_map: GridContainer):
	chunk_size = World.chunk_size
	full_size = chunk_size * 4
	var existing_tiles = grid_map.get_children()
	for tile in existing_tiles:
		tile.queue_free()
	World.tiles = {}
	grid_map.columns = full_size

func generate_basic_grid():
	for y in range(full_size):
		for x in range(full_size):
			var current_pos = [x,y]
			var tile_data = {
				"coords": current_pos,
				"discovered": true
			}
			world_tiles[current_pos] = tile_data
