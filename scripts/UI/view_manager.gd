extends Control

@onready var panel_inventory: Panel = $Panel_Inventory
@onready var panel_map: Panel = $Panel_Map
@onready var panel_quests: Panel = $Panel_Quests
@onready var panel_logs: Panel = $Panel_Logs
@onready var panel_settings: Panel = $Panel_Settings
#var main_menu = preload("res://assets/button_group_main.tres")

func _ready() -> void:
	pass # Replace with function body.


# functional
func _on_button_save_pressed() -> void:
	Save.save_session()


# ui
## top bar
func _on_button_inventory_toggled(toggled_on: bool) -> void:
	panel_inventory.visible = toggled_on


func _on_button_map_toggled(toggled_on: bool) -> void:
	panel_map.visible = toggled_on


func _on_button_quests_toggled(toggled_on: bool) -> void:
	panel_quests.visible = toggled_on


func _on_button_log_toggled(toggled_on: bool) -> void:
	panel_logs.visible = toggled_on


func _on_button_settings_toggled(toggled_on: bool) -> void:
	panel_settings.visible = toggled_on
