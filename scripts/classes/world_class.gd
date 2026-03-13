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

var patches: Dictionary[Rect2i, String]
var empty_patches: Array = ["Ice", "Sea", "Mountain"]
var workable_patches: Array[String]

var world_tiles: Dictionary[Array, Dictionary]


func recreate_world(grid_map):
	reset_world(grid_map)
	workable_patches = Shared.COLOUR_MAP.keys().filter(
		func(key): return not empty_patches.has(key)
	)
	determine_patches()
	generate_basic_grid()
	patch_application()
	ruffle_edges()
	locations()
	#tile_deviation()
	tile_check()
	World.tiles = world_tiles
	Save.save_world()

func tile_check():
	for tile in world_tiles:
		var target_tile = world_tiles[tile]
		if target_tile["poi"]:
			if target_tile["tile_type"] == "Basic":
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
	var available_patches: Array[String] = workable_patches.duplicate()
	var missing_cultures: Array[String] = ["Time", "Space", "Mystic"]
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

func unpack_patch(patch: Rect2i):
	var patch_tiles: Array
	for y in range(patch.position.y, patch.end.y):
		for x in range(patch.position.x, patch.end.x):
			patch_tiles.append([x,y])

	return patch_tiles


func generate_basic_grid():
	var basic_tile = {
		"discovered": true,
		"essence": "Sea",
		"tile_type": "Basic",
		"poi" : false
	}
	for y in range(full_size):
		for x in range(full_size):
			var current_pos = [x,y]
			var tile_data = basic_tile.duplicate()
			tile_data["coords"] = current_pos
			world_tiles[current_pos] = tile_data


func patch_application():
	for patch in patches:
		var patch_tiles = unpack_patch(patch)
		for patch_tile in patch_tiles:
			world_tiles[patch_tile]["essence"] = patches[patch]


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
		var patch_essence = patches[patch]
		if patch_essence in empty_patches:
			continue

		minor_locations(patch)

		for major in ["Capital", "City", "Town"]:
			var target_coords
			if major == "Capital":
				target_coords = random_point_in_patch(patch, half_chunk) 
			if major == "City":
				target_coords = random_point_in_patch(patch, chunk_size - half_chunk / 2)
			if major == "Town":
				target_coords = random_point_in_patch(patch, chunk_size-1 - 2) 
		
			var target_tile = world_tiles[target_coords]
			
			target_tile["tile_type"] = major
			target_tile["essence"] = patch_essence
			target_tile["poi"] = true

			world_tiles[target_coords] = target_tile

#TODO: Weird generation going on
func minor_locations(patch: Rect2i):
	var patch_tiles = unpack_patch(patch)
	for patch_tile in patch_tiles:
		var target_tile = world_tiles[patch_tile]
		if target_tile["essence"] == "Sea" and randf() <= 0.25:
			target_tile["tile_type"] = "Port"

		elif target_tile["essence"] == "Mountain" and randf() <= 0.5:
			target_tile["tile_type"] = "Cave"

		elif randf() <= 0.15:
			target_tile = deviate_tile(target_tile, patches[patch])

		if target_tile["tile_type"] != "Basic":
			target_tile["poi"] = true
			world_tiles[patch_tile] = target_tile
			
func deviate_tile(target_tile, base_essence):
	var deviation_type = ["essence", "minor"].pick_random()
	match deviation_type:
		"essence":
			var acceptable_essences = workable_patches.duplicate()
			acceptable_essences.erase(base_essence)
			var new_essence = acceptable_essences.pick_random()
			target_tile["tile_type"] = target_tile["essence"]
			target_tile["essence"] = new_essence
		"minor":
			var new_type = TYPE_LIST.pick_random()
			target_tile["tile_type"] = new_type

	return target_tile



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
