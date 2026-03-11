extends MapGenerator

@onready var grid_map: GridContainer = $Scroll_Map/Center/Grid_Map
@onready var spinbox_cellsize: SpinBox = $VBox_Window/HBoxSettings/Fold_Settings/Grid_Settings/SpinBox_CellSize
@onready var button_small: Button = $VBox_Window/HBoxSettings/Button_Small
@onready var button_big: Button = $VBox_Window/HBoxSettings/Button_Big

var button_tile: PackedScene = preload("res://prefabs/button_tile.tscn")
var astar_grid: AStarGrid2D

var button_map: Dictionary

func _ready() -> void:
	grid_map.columns = World.chunk_size * World.chunk_segments
	update_cell_size(Settings.map["Cell Size"])
	#if len(World.tiles) == 0:
	recreate_world(grid_map)
	for tile in World.tiles:
		create_tile(tile)
			
func create_tile(tile: Array):
	var tile_data: MapTileData = MapTileData.new(tile)
	var tile_display: Button = button_tile.instantiate()
	tile_display.data = tile_data
	grid_map.add_child(tile_display)
	button_map[tile_data.coords] = tile_display

func update_cell_size(new_value: int):
	Settings.map["Cell Size"] = new_value
	spinbox_cellsize.value = new_value
	button_small.disabled = true if new_value == 8 else false
	button_big.disabled = true if new_value == 64 else false
	for button in button_map:
		button_map[button].custom_minimum_size = Vector2(new_value, new_value)
	#update astat when implement
	Save.save_settings()

func _on_spin_box_cell_size_value_changed(value: int) -> void:
	update_cell_size(value)


func _on_button_small_pressed() -> void:
	update_cell_size(spinbox_cellsize.value - 4)

func _on_button_big_pressed() -> void:
	update_cell_size(spinbox_cellsize.value + 4)
