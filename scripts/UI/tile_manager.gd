extends MapGenerator

@onready var grid_map = $VBox_Window/Scroll_Map/Grid_Map

func _ready() -> void:
	if len(World.tiles) == 0:
		recreate_world(grid_map)
