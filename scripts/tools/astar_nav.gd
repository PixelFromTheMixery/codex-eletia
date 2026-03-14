extends AStar2D

class_name AstarNav

var world_size: int

func _init() -> void:
	reset_astar()
	

func reset_astar():
	world_size = World.chunk_segments * World.chunk_size
	clear()
	
func generate_mapping(world_tiles):
	var id = 0
	for tile in world_tiles:
		add_point(id, Vector2(tile[0], tile[1]))
		id += 1
	
	# Connect ALL tiles together, including wrapping
	
	for tile in world_tiles:
		var tile_info = world_tiles[tile]
		var x = tile[0]
		var y = tile[1]
		
		var right_x = (x + 1) % world_size
		var down_y = (y + 1) % world_size
		
		var right_id = (y * world_size) + right_x
		var down_id = (down_y * world_size) + x
		
		connect_points(tile_info["instance"], right_id, true)
		connect_points(tile_info["instance"], down_id, true)
