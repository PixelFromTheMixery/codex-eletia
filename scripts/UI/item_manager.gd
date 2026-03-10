extends Node

@onready var inventory = $VBox_Window/Scroll/VBox
@onready var weight_display = $VBox_Window/HBox_Filter/Panel_Weight/Label_Weight

var item = preload("res://prefabs/vbox_item.tscn")
var item_pool: Dictionary[String, InventoryItem]
var tag_pool: Dictionary
var target_item: InventoryItem

# Startup
func _ready() -> void:
	SignalBus.add_item.connect(add_item)
	SignalBus.remove_item.connect(remove_item)
	load_inventory()


func load_inventory():
	"""Initial load of player inventory"""
	for item_entry in Player.inventory:
		if Player.inventory[item_entry]["qty"] != 0:
			display_new_item(item_entry)
	for item_entry in item_pool:
		Player.stats["current_weight"] += item_pool[item_entry].data.total_weight
	update_weight_display()

# Fetch
func get_inv_item(item_id: String):
	"""Fetches item object from pool, should be mapped to object"""
	return item_pool.get(item_id)

# Update UI
func update_weight_display():
	"""Updates player weight display"""
	weight_display.text = "%.1f/%.1f" % [Player.stats["current_weight"], Player.stats["max_weight"]]


func display_new_item(item_id: String):
	"""Adds item to VBox hosted at the UI element"""
	var new_item = ItemData.new(item_id)
	var new_item_display = item.instantiate()
	new_item_display.data = new_item
	inventory.add_child(new_item_display)
	item_pool[item_id] = new_item_display


func add_item(target_item_id:String, new_qty: int):
	"""Creates or modifies item in display"""
	target_item = get_inv_item(target_item_id)
	if target_item:
		Player.stats["current_weight"] += target_item.data.unit_weight * new_qty
		update_weight_display()
		target_item.data.item_qty += new_qty
		target_item.refresh_ui_labels()
	else:
		Player.inventory[target_item_id] = {"qty": new_qty}
		display_new_item(target_item_id)
		Player.stats["current_weight"] += item_pool[target_item_id].data.total_weight
		update_weight_display()
	target_item = null


func remove_item(target_item_id: String, target_qty: int):
	"""Removes or modifies item in display"""
	target_item = get_inv_item(target_item_id)
	if target_item:
		if target_item.data.qty - target_qty <= 0:
			Player.inventory.erase(target_item_id)
			Player.stats["current_weight"] -= target_item.data.total_weight
			item_pool[target_item_id].queue_free()
			item_pool.erase(target_item_id)
		else:
			Player.stats["current_weight"] -= target_item.data.unit_weight * target_qty
			target_item.data.qty -= target_qty
		update_weight_display()
		target_item.refresh_ui_labels()
	else:
		SignalBus.create_alert.emit("Item %s not found in inventory" % target_item_id)
	target_item = null


func _on_text_search_text_changed() -> void:
	pass
	

func _on_option_button_item_selected(index: int) -> void:
	print(index)
