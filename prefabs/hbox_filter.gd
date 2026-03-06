extends Node

@onready var text_search = $Text_Search
@onready var option_filters = $Option_Filters

func _on_button_clear_pressed() -> void:
	"""Clears search text"""
	text_search.clear()
