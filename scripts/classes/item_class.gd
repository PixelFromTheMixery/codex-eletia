extends Resource

class_name ItemData

@export var item_id: String
@export var item_name: String
@export var unit_weight: float
@export var tags: Array[String]

func sync_to_player(key: String, value):
	Player.inventory[item_id][key] = value

var qty: int:
	set(value):
		qty = value
		calculate_weights()
		sync_to_player("qty", value)

# Derived Data (Calculated for display)
@export var total_weight: float

func _init(item_id_string: String):
	"""Creates instance of ItemData based on ID reference in library and Player"""
	self.item_id = item_id_string

	var lib_entry = Data.items.get(item_id, {})
	if lib_entry.is_empty():
		push_error("Item ID %s not found in Library!" % item_id)
		return
	self.item_name = lib_entry.get("item_name", "Unknown Item")
	self.unit_weight = lib_entry.get("unit_weight", 0.0)
	self.tags.assign(lib_entry.get("tags", []))

	var player_entry = Player.inventory.get(item_id, {"qty": 0})
	self.qty = player_entry["qty"]

func calculate_weights() -> void:
	"""recalculates total weight based on class qty"""
	total_weight = unit_weight * qty
