extends Node

class_name LogItem

@onready var label_type = $HBox_Details/Label_Type
@onready var label_detail = $HBox_Details/Label_Detail

var data: LogData

func _ready() -> void:
	"""Instance applies data during generation"""
	label_type.text = data.log_type
	label_detail.text = data.content
