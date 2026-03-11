extends AStarGrid2D

var world_size = World.chunk_size*World.chunk_segments

func _init() -> void:
	cell_shape = CELL_SHAPE_SQUARE
	region = Rect2i(0, 0, world_size, world_size)
	cell_size = Settings.map["Cell Size"]
	diagonal_mode = DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	update()

func update_map_pres(new_size):
	cell_size = Settings.map["Cell Size"]
	update()

#func _compute_cost(from_coords: Vector2i, to_coords: Vector2i) -> float:
	# Needs to be overwritten for wrapping

#func _compute_etimate(from_coords: Vector2i, to_coords: Vector2i) -> float:
	# Needs to be overwritten for wrapping

func get_terrain_weight_at(pos: Vector2) -> float:
	return World.tiles[[pos.x,pos.y]]["terrain"]
	
func wrapped_distance(a: Vector2, b: Vector2) -> float:
	"""
	Used to check the distance for map wrap.
	If the distance is more than half the map, the wrap-around is shorter
	"""
	
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)

	if dx > world_size.x / 2:
		dx = world_size.x - dx
	if dy > world_size.y / 2:
		dy = world_size.y - dy
			
	return max(dx*dx + dy*dy)
