extends Node

@onready var window = self.get_parent()

func _on_pressed() -> void:
	"""Hides window"""
	window.hide()
