extends Node

class_name MapGenerator

const OFFSETS = {
	"top": [0, -1], 
	"bottom": [0, 1], 
	"left" :[-1, 0], 
	"right" :[1, 0],   
	"top_left": [-1, -1], 
	"top_right": [1, -1], 
	"bottom_left": [-1, 1], 
	"bottom_right": [1, 1]
}

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
var essence_list: Array = Shared.COLOUR_MAP.keys().duplicate()

var world_tiles: Dictionary[Array, Dictionary]


# Utility functions
func unpack_patch(patch: Rect2i):
	var patch_tiles: Array
	for y in range(patch.position.y, patch.end.y):
		for x in range(patch.position.x, patch.end.x):
			patch_tiles.append([x,y])

	return patch_tiles


func get_edge_data(rect: Rect2i) -> Array:
	var list = []
	
	var left = rect.position.x
	var top = rect.position.y
	var right = rect.end.x - 1
	var bottom = rect.end.y - 1

	var add_tile = func(tx, ty, side):
		var wrapped_x = posmod(tx, full_size)
		var wrapped_y = posmod(ty, full_size)
		
		var array_index = (wrapped_y * full_size) + wrapped_x
		
		list.append({
			"pos": [wrapped_x, wrapped_y], 
			"index": array_index, 
			"side": side
		})

	for x in range(left, right + 1):
		add_tile.call(x, top, "top")
		if bottom > top: add_tile.call(x, bottom, "bottom")

	for y in range(top + 1, bottom):
		add_tile.call(left, y, "left")
		if right > left: add_tile.call(right, y, "right")

	return list

# World Creation
func recreate_world(grid_map):
	reset_world(grid_map)

	determine_patches()
	generate_basic_grid()

	generate_continents()

	diversify_patches()

	poi_collection()

	tile_check()
	World.tiles = world_tiles
	Save.save_world()


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

# Whole map
func determine_patches():
	var applicable_essences: Array[String] = essence_list
	var missing_cultures: Array = ["Time", "Space", "Mystic"] + empty_patches
	missing_cultures.append_array(empty_patches)
	applicable_essences = applicable_essences.filter(func(patch): 
		return not patch in missing_cultures
	)

	while len(applicable_essences) < segments*(segments-2):
		if randf() < 0.75:
			applicable_essences.append("Sea")
		else:
			applicable_essences.append("Mountain")
	applicable_essences.shuffle()

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
				essence = applicable_essences.pop_back()

			var rect = Rect2i(x * chunk_size, y_offset, chunk_size, current_chunk_h)
			patches[rect] = essence


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


func generate_continents():
	for patch in patches:
		for patch_tiles in unpack_patch(patch):
			patch_application(patch_tiles, patches[patch])

	for patch in patches:
		ruffle_edges(patch)


func patch_application(patch_tile: Array, base_essence: String):
	world_tiles[patch_tile]["essence"] = base_essence


func ruffle_edges(patch):
	for tile_data in get_edge_data(patch):
		var pos = tile_data.pos
		var actual_tile = world_tiles[pos] 

		var neighbours = tile_neighbours(pos[0], pos[1], 4)
		var possible_sides = [tile_data.side]

		if tile_data.side == "top" or tile_data.side == "bottom":
			possible_sides.append(tile_data.side + "_left")
			possible_sides.append(tile_data.side + "_right")
		elif tile_data.side == "left" or tile_data.side == "right":
			possible_sides.append("top_" + tile_data.side)
			possible_sides.append("bottom_" + tile_data.side)

		if randf() < 0.4:
			var chosen_side = possible_sides[randi() % possible_sides.size()]
			var offset = OFFSETS[chosen_side]
			if neighbours.has(offset):
				actual_tile["essence"] = neighbours[offset]["essence"]


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


# Per patch
func diversify_patches():
	var acceptable_essences = essence_list.duplicate()
	acceptable_essences.erase("Ice")
	var acceptable_patches = {}
	var anti_patches = {}

	for patch in patches:
		if patches[patch] not in empty_patches:
			acceptable_patches[patch] = patches[patch] 

	# Anti-patches

	# POI
	var radical_chance = 0.10
	for patch in acceptable_patches:
		transit_tiles(patch) 
		var patch_tiles = unpack_patch(patch)
		var patch_essence = patches[patch]
		for patch_tile in patch_tiles:
			radical_locations(patch_tile, radical_chance, patch_essence, acceptable_essences)
		unique_locations(patch, patch_essence)
	

func transit_tiles(patch: Rect2i):
	var edges = {
		"top": [],
		"bottom": [],
		"left": [],
		"right": []
	}


	for tile_data in get_edge_data(patch):
		edges[tile_data["side"]].append(tile_data["pos"])

	var edge_tiles = {
		"top": {},
		"bottom": {},
		"left": {},
		"right": {}
	}
	
	var edge_types = {}
	
	for side in edges.keys():
		for tile in edges[side]:
			var target_tile = world_tiles.get(tile)
			if target_tile == null: continue
			if side not in edge_types:
				if target_tile["essence"] in ["Sea", "Mountain"]:
					edge_types[side] = target_tile["essence"]
			edge_tiles[side][tile] = world_tiles[tile]


	for side in edge_types.keys():
		var transit_count: int = 0
		var spawn_chance: float = 0.6
		var side_essence: String = edge_types[side]
		var type_name: String = "Port" if side_essence == "Sea" else "Cave"

		var tiles_to_check = edge_tiles[side].keys()
		tiles_to_check.shuffle()

		for tile in tiles_to_check:
			if transit_count >= 2: break

			var tile_data = edge_tiles[side][tile]

			if tile_data.get("essence") == side_essence:
				if randf() < spawn_chance:
					tile_data["tile_type"] = type_name
					transit_count += 1
					world_tiles[tile] = tile_data


func radical_locations(patch_tile, radical_chance, base_essence, acceptable_essences):
	var target_tile = world_tiles[patch_tile]
	if randf() <= radical_chance and target_tile["essence"] not in empty_patches:
		var deviation_type = ["essence", "minor"].pick_random()
		match deviation_type:
			"essence":
				acceptable_essences.erase(base_essence)
				var new_essence = acceptable_essences.pick_random()
				target_tile["tile_type"] = new_essence
			"minor":
				var new_type = TYPE_LIST.pick_random()
				target_tile["tile_type"] = new_type

		world_tiles[patch_tile] = target_tile


func unique_locations(patch, base_essence):
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
		target_tile["essence"] = base_essence


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






# Data cleanup
func poi_collection():
	for tile in world_tiles:
		if world_tiles[tile]["tile_type"] != "Basic":
				world_tiles[tile]["poi"] = true


func tile_check():
	for tile in world_tiles:
		var target_tile = world_tiles[tile]
		if target_tile["poi"]:
			pass
		
