extends Button

func emitter(button_id: int):
	SignalBus.create_alert.emit("Button %s was pressed. Something should have happened" % button_id)

func _on_pressed() -> void:
	SignalBus.add_item.emit("AnotherTestItem", 3)
	#SignalBus.create_log.emit("Debug", "Meep")
	emitter(1)


func _on_button_test_2_pressed() -> void:
	SignalBus.remove_item.emit("AnotherTestItem", 1)
	emitter(2)
