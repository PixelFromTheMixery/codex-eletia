extends Node

@onready var vbox_actions: VBoxContainer = $VBox_Window/Scroll/VBox

var action_scene = preload("res://prefabs/vbox_action.tscn")

var action_pool: Dictionary

func _ready() -> void:
	var new_action = ActionData.new()
	new_action.action_id = "gather"
	new_action.action = "Gather"
	new_action.action_name = "Search the area for items"
	new_action.req = [{	
				"type":	"item",
				"id": "TestItem", 
				"qty": 1
			}]
	new_action.rew = [{	
				"type":	"item",
				"id": "AnotherTestItem", 
				"qty": 1
			}]
	new_action.time = 3
	new_action.tags = ["test"]
	
	var new_action_display = action_scene.instantiate()
	new_action_display.data = new_action
	action_pool["gather"] = new_action_display
	vbox_actions.add_child(new_action_display)
