extends Node


var alert = preload("res://prefabs/progress_alert.tscn")

func _ready() -> void:
	SignalBus.create_alert.connect(create_alert)

func create_alert(message: String):
	"""Limits logs to 3 before instantiating"""
	var count = self.get_child_count()
	if count > 2:
		self.get_child(-1).free()
	var new_alert = alert.instantiate()
	new_alert.timeout = Settings.general["Alert Timeout"]
	new_alert.message = message
	self.add_child(new_alert)
