extends Node 

class_name InventoryItem

@onready var label_qty: Label = $HBox_Basic/Label_Qty
@onready var label_name: Label = $HBox_Basic/Label_Name
@onready var label_wgt: Label = $HBox_Detail/Label_Wgt
@onready var tag_list: HFlowContainer = $HBox_Detail/HFlow_Tags
@onready var spinbox_drop: SpinBox = $HBox_Detail/SpinBox_Drop
@onready var button_drop: Button = $HBox_Detail/Button_Drop

var tag_scene = preload("res://prefabs/panel_cont_tag.tscn")
var data: ItemData

func refresh_ui_labels():
	"""Recurrent UI update method"""
	label_qty.text = str(data.qty)
	label_wgt.text = str(data.total_weight)
	spinbox_drop.max_value = data.qty

func _ready() -> void:
	"""Instance applies data during generation"""
	# Fixed
	name = "VBox_Item_%s" % data.item_id
	label_name.text = data.item_name
	for tag in data.tags:
		var new_tag = tag_scene.instantiate()
		new_tag.tag_name = tag
		tag_list.add_child(new_tag)
	refresh_ui_labels()


func _on_button_drop_pressed() -> void:
	"""Removes item from inventory"""
	SignalBus.remove_item.emit(data.item_id, spinbox_drop.value)
	refresh_ui_labels()
	spinbox_drop.value = 0

func _on_spin_box_drop_value_changed(_value: float) -> void:
	"""Check if amount can be dropped"""
	if spinbox_drop.value == 0:
		button_drop.disabled = true
	else:
		button_drop.disabled = false
