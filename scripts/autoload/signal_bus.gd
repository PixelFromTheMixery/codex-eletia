extends Node

# logging
signal create_log(log_type: String, log_detail: String)
signal create_alert(message: String)

# inventory
signal add_item(item_id: String, qty: int)
signal remove_item(item_id: String, qty: int)

func _ready() -> void:
	create_log.get_name()
	create_alert.get_name()
	add_item.get_name()
	remove_item.get_name()
