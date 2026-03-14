extends Node

@onready var grid_map: GridContainer = $VBox_Window/Scroll_Map/Center/Grid_Map
@onready var spinbox_cellsize: SpinBox = $VBox_Window/HBoxSettings/Fold_Settings/Grid_Settings/SpinBox_CellSize
@onready var button_small: Button = $VBox_Window/HBoxSettings/Button_Small
@onready var button_big: Button = $VBox_Window/HBoxSettings/Button_Big

@onready var label_coords: Label = $VBox_Window/HBox_Tile/Fold_TileInfo/VBox_TileInfo/Label_Coords
@onready var label_essence: Label = $VBox_Window/HBox_Tile/Fold_TileInfo/VBox_TileInfo/Label_Essence
@onready var label_type: Label = $VBox_Window/HBox_Tile/Fold_TileInfo/VBox_TileInfo/Label_Type

var map_generator: MapGenerator = MapGenerator.new()
var astar_nav: AstarNav = AstarNav.new()

var button_tile: PackedScene = preload("res://prefabs/button_tile.tscn")
var cell_size: int

var buttons_map: Dictionary[Array, Button]
var buttons_poi: Dictionary[Array, Button]

func _ready() -> void:
	grid_map.columns = World.chunk_size * World.chunk_segments
	cell_size = Settings.map["Cell Size"]
	#if len(World.tiles) == 0:
	map_generator.recreate_world(grid_map, astar_nav)
	for tile in World.tiles:
		create_tile(tile)
	update_cell_size(cell_size)


func create_tile(tile: Array):
	var tile_data: MapTileData = MapTileData.new(tile)
	var tile_display: Button = button_tile.instantiate()
	tile_display.data = tile_data
	tile_display.custom_minimum_size = Vector2(cell_size, cell_size)
	tile_display.tile_info.connect(update_tile_info)
	grid_map.add_child(tile_display)
	buttons_map[tile_data.coords] = tile_display
	if tile_data.poi:
		buttons_poi[tile_data.coords] = tile_display

func update_tile_info(coords:Array):
	var tile_data = buttons_map[coords].data
	label_coords.text = "(%0d,%0d)" % [tile_data["coords"][0],tile_data["coords"][1]]
	label_essence.text = tile_data["essence"]
	label_type.text = tile_data["tile_type"]

func update_cell_size(new_value: int):
	Settings.map["Cell Size"] = new_value
	spinbox_cellsize.value = new_value
	button_small.disabled = true if new_value == 8 else false
	button_big.disabled = true if new_value == 64 else false
	for button in buttons_map.values():
		button.custom_minimum_size = Vector2(new_value, new_value)
	for button in buttons_poi.values():
		button.update_icon(new_value)
	#update astat when implement
	Save.save_settings()

func _on_spin_box_cell_size_value_changed(value: int) -> void:
	update_cell_size(value)

func _on_button_small_pressed() -> void:
	update_cell_size(spinbox_cellsize.value - 4)

func _on_button_big_pressed() -> void:
	update_cell_size(spinbox_cellsize.value + 4)
