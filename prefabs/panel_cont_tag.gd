extends Node

@onready var label_tag = $Label_Tag

var tag_name: String

func _ready() -> void:
	"""Instance applies data during generation"""
	label_tag.text = " #%s " % tag_name
