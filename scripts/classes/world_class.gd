extends Node

class_name MapGenerator

const OFFSETS = [
	[0, -1], [0, 1], [-1, 0], [1, 0],   # Cardinals
	[-1, -1], [1, -1], [-1, 1], [1, 1]  # Diagonals
]

const TYPE_LIST: Array[String] = [
	"Outpost",
	"Colony",
	"Refuge",
	"Hamlet",
	"Fort",
	"Sanctuary",
	"Stronghold"
]

const PATH_LIST: Dictionary[String, int] = {
	"Trail": 2,
	"Path": 1,
	"Road": 0,
}


var chunk_size: int
var half_chunk: int
var segments: int
var full_size: int
var colour_keys: Array[String] = Shared.COLOUR_MAP.keys().duplicate()

var world_tiles: Dictionary[Array, Dictionary]
var patches: Dictionary[Rect2i, String]
var empty_patches: Array = ["Ice", "Sea", "Mountain"]
var astar: AStarGrid2D
var poi_map: Dictionary[Array, Dictionary]


func recreate_world(grid_map):
	reset_world(grid_map)
	determine_patches()
	generate_basic_grid()
	patch_application()
	#tile_check()
	ruffle_edges()
	locations()
	#tile_deviation()
	World.tiles = world_tiles
	Save.save_world()

func tile_check():
	for tile in world_tiles:
		if "essence" not in world_tiles[tile].keys():
			pass

func reset_world(grid_map: GridContainer):
	chunk_size = World.chunk_size
	half_chunk = chunk_size / 2
	segments = World.chunk_segments
	full_size = chunk_size * segments
	var existing_tiles = grid_map.get_children()
	for tile in existing_tiles:
		tile.queue_free()
	World.tiles = {}
	grid_map.columns = full_size

func determine_patches():
	var available_patches: Array[String] = colour_keys.duplicate()
	var missing_cultures: Array[String] = ["Time", "Space", "Mystic", "Ice"]
	available_patches = available_patches.filter(func(patch): 
		return not patch in missing_cultures
	)

	while len(available_patches) < segments*(segments-2):
		if randf() < 0.75:
			available_patches.append("Sea")
		else:
			available_patches.append("Mountain")
	available_patches.shuffle()

	for y in range(segments):
		for x in range(segments):
			var current_chunk_h = chunk_size
			var y_offset = 0
			var essence = "Ice"
			if y == 0:
				current_chunk_h = half_chunk
				
			elif y == segments - 1:
				current_chunk_h = half_chunk
				y_offset = (y * chunk_size) + (half_chunk)
			else:
				y_offset = (y * chunk_size)
				essence = available_patches.pop_back()

			var rect = Rect2i(x * chunk_size, y_offset, chunk_size, current_chunk_h)
			patches[rect] = essence


func generate_basic_grid():
	for y in range(full_size):
		for x in range(full_size):
			var current_pos = [x,y]
			var tile_data = {
				"coords": current_pos,
				"discovered": true,
				"essence": "Sea",
				"tile_type": "Basic"
			}
			world_tiles[current_pos] = tile_data


func patch_application():
	for patch in patches:
		for y in range(patch.position.y, patch.end.y):
			for x in range(patch.position.x, patch.end.x):
				var current_pos = [x,y]
				world_tiles[current_pos]["essence"] = patches[patch]


func ruffle_edges():
	var edge_to_offset_idx = {
		"top": 0,
		"bottom": 1,
		"left": 2,
		"right": 3
	}
	for patch in patches:
		for tile_data in get_edge_data(patch):
			var pos = tile_data.pos
			var actual_tile = world_tiles[pos] 

			var neighbours = tile_neighbours(pos[0], pos[1], chunk_size/4)

			var idx = edge_to_offset_idx[tile_data.side]
			var neighbor_tile = neighbours[OFFSETS[idx]]

			if randf() < 0.6:
				actual_tile["essence"] = neighbor_tile["essence"]

func locations():
	for patch in patches:
		if patches[patch] in empty_patches:
			continue
		
		var capital = random_point_in_patch(patch, half_chunk) 
		var city = random_point_in_patch(patch)
		var town = random_point_in_patch(patch)
		
		var target_tile = world_tiles[capital]
		target_tile["tile_type"] = "Capital"
		poi_map[capital] = target_tile
		world_tiles[capital] = target_tile

func random_point_in_patch(patch: Rect2i, modifier: int = 0) -> Array[int]:
	return [randi_range(
		patch.position.x + modifier, 
		patch.end.x - 1 - modifier
		), 
		randi_range(
			patch.position.y + modifier, 
			patch.end.y-1 - modifier
		)
	]

func get_edge_data(rect: Rect2i) -> Array:
	var list = []
	var left = rect.position.x
	var top = rect.position.y
	var right = rect.end.x - 1
	var bottom = rect.end.y - 1

	var add_tile = func(tx, ty, side):
		list.append({"pos": [tx, ty], "side": side})

	for x in range(left, right + 1):
		add_tile.call(x, top, "top")
		if bottom > top: add_tile.call(x, bottom, "bottom")

	for y in range(top + 1, bottom):
		add_tile.call(left, y, "left")
		if right > left: add_tile.call(right, y, "right")

	return list


func tile_neighbours(x:int, y:int, depth: int = 1):
	var neighbours = {}
	for ox in range(-depth, depth + 1):
		for oy in range(-depth, depth + 1):
			if ox == 0 and oy == 0:
				continue

			# Calculate wrapped coordinates
			var new_x = (x + ox + full_size) % full_size
			var new_y = (y + oy + full_size) % full_size

			neighbours[[ox, oy]] = world_tiles.get([new_x, new_y])
	return neighbours

func tile_deviation():
	var deviation = chunk_size/100
	for tile in world_tiles.values():
		if randf() < deviation:
			var new_essence = colour_keys.pick_random()
			if tile["essence"] != new_essence and tile["essence"] not in empty_patches:
				tile["type"] = tile["essence"]
				tile["essence"] = new_essence
				tile["tile_id"] = tile["type"]+new_essence
				poi_map[tile["coords"]] = tile
