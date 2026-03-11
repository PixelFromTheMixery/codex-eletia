extends Node

class_name MapGenerator

const OFFSETS = [
	[0, -1], [0, 1], [-1, 0], [1, 0],   # Cardinals
	[-1, -1], [1, -1], [-1, 1], [1, 1]  # Diagonals
]

const TYPE_LIST: Array[String] = [
	"Path",
	"Outpost",
	"Colony",
	"Refuge",
	"Hamlet",
	"Fort",
	"Sanctuary",
	"Stronghold"
]


var chunk_size: int
var segments: int
var full_size: int
var colour_keys: Array[String] = Shared.COLOUR_MAP.keys().duplicate()

var world_tiles: Dictionary[Array, Dictionary]
var patches: Dictionary[Rect2i, String]
var astar: AStarGrid2D
var poi_map: Dictionary[Array, Dictionary]



func recreate_world(grid_map):
	reset_world(grid_map)
	determine_patches()
	generate_basic_grid()
	patch_application()
	ruffle_edges()
	#locations()
	#tile_deviation()
	World.tiles = world_tiles
	Save.save_world()

func reset_world(grid_map: GridContainer):
	chunk_size = World.chunk_size
	segments = World.chunk_segments
	full_size = chunk_size * segments
	var existing_tiles = grid_map.get_children()
	for tile in existing_tiles:
		tile.queue_free()
	World.tiles = {}
	grid_map.columns = full_size

func determine_patches():
	var available_patches: Array[String] = colour_keys.duplicate()
	for colour in colour_keys.duplicate():
		if randf() < 0.5:
			available_patches.append(colour)
	var missing_cultures: Array[String] = ["Time", "Space", "Mystic"]
	available_patches = available_patches.filter(func(patch): 
		return not patch in missing_cultures
	)

	while len(available_patches) < segments*segments :
		if randf() < 0.75:
			available_patches.append("Sea")
		else:
			available_patches.append("Mountain")
	available_patches.shuffle()

	for y in range(segments):
		for x in range(segments):
			if not available_patches.is_empty():
				patches[Rect2i(chunk_size*x, chunk_size*y, chunk_size,chunk_size)]= available_patches.pop_back()


func generate_basic_grid():
	for y in range(full_size):
		for x in range(full_size):
			var current_pos = [x,y]
			var tile_data = {
				"coords": current_pos,
				"discovered": true
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

			var neighbours = tile_neighbours(pos[0], pos[1], 2)

			var idx = edge_to_offset_idx[tile_data.side]
			var neighbor_tile = neighbours[OFFSETS[idx]]

			if randf() < 0.4:
				actual_tile["essence"] = neighbor_tile["essence"]


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
	for tile in world_tiles:
		if randf() < 0.15:
			var new_essence = colour_keys.pick_random()
			var current_tile = world_tiles[tile]
			if current_tile["essence"] != new_essence and current_tile["essence"] not in ["Sea", "Mountain"]:
				current_tile["type"] = current_tile["essence"]
				current_tile["essence"] = new_essence
				current_tile["tile_id"] = current_tile["type"]+new_essence
				world_tiles[tile] = current_tile
				poi_map[current_tile["coords"]] = current_tile
