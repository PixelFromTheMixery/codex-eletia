extends MapGenerator

@onready var grid_map: GridContainer = $VBox_Window/Scroll_Map/Grid_Map

var button_tile: PackedScene = preload("res://prefabs/button_tile.tscn")

var button_map: Dictionary

func _ready() -> void:
	grid_map.columns = World.chunk_size * 4
	#if len(World.tiles) == 0:
	recreate_world(grid_map)
	for tile in World.tiles:
		create_tile(tile)
			
func create_tile(tile: Array):
	var tile_data: MapTileData = MapTileData.new(tile)
	var tile_display: Button = button_tile.instantiate()
	tile_display.data = tile_data
	grid_map.add_child(tile_display)
	# add to button_map
