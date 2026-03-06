extends Node

@onready var log_obj = $VBox_Window/Scroll/VBox
@onready var fold_settings = $VBox_Window/HBox_Settings/Fold_Filters/VBox_Filters

var log_prefab = preload("res://prefabs/vbox_log.tscn")
var log_pool = {}

func _ready() -> void:
	SignalBus.create_log.connect(create_log)
	generate_log_settings()


func generate_log_settings():
	"""Creates toggle for every log type"""
	for key in Settings.logs:
		var new_check = CheckButton.new()
		new_check.text = key
		new_check.button_pressed = Settings.logs[key]
		new_check.toggled.connect(_on_log_setting_toggled.bind(key))
		fold_settings.add_child(new_check)
		log_pool[key] = []


func _on_log_setting_toggled(on_toggled: bool, setting_name: String):
	"""Updates visibility of log type based on type"""
	Settings.logs[setting_name] = on_toggled
	var type_logs = get_logs(setting_name)
	for log_entry in type_logs:
		log_entry.visible = on_toggled


func create_log(log_type: String, log_detail: String ) -> void:
	"""Creates log based on signal"""
	var new_log_display: LogItem = log_prefab.instantiate()
	var new_log = LogData.new(log_type, log_detail)
	log_pool[log_type].append(new_log_display)
	new_log_display.data = new_log
	new_log_display.visible = Settings.logs[log_type]
	log_obj.add_child(new_log_display)


func get_logs(scope: String) -> Array:
	"""Retrieves logs based on log type"""
	match scope:
		"all":
			return log_obj.get_children()
		_:
			if scope in log_pool.keys():
				return log_pool[scope]
			else:
				SignalBus.create_alert.emit("Scope %s not found in log pool" % scope)
				return []


func _on_button_clear_pressed() -> void:
	"""Clears logs for visibility"""
	for log_item in get_logs("all"):
		log_item.queue_free()
	for key in log_pool:
		log_pool[key].clear()
