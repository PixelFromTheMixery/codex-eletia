extends ProgressBar

@onready var label: Label = $Label_Alert

var message: String
var timeout: int

func _ready() -> void:
	"""Starts alert timer with instance message"""
	label.text = message
	self.max_value = timeout
	get_tree().create_timer(timeout).timeout.connect(queue_free)

func _process(delta: float) -> void:
	"""Starts Progress timer"""
	self.value += delta

func _on_button_close_pressed() -> void:
	"""User delete option"""
	self.queue_free()
