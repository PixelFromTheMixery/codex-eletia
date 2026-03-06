extends VBoxContainer

@onready var label_title: Label = $Label_Title
@onready var hbox_tags: HBoxContainer = $HBox_Tags
@onready var vbox_reqs: VBoxContainer = $HBox_Info/VBox_Req
@onready var vbox_rews: VBoxContainer = $HBox_Info/VBox_Rew
@onready var progress: ProgressBar = $HBox_Action/Progress_Action
@onready var label_progress: Label = $HBox_Action/Progress_Action/Label_Progress
@onready var button_action: Button = $HBox_Action/Button_Action

var tag_scene = preload("res://prefabs/panel_cont_tag.tscn")

var data: ActionData
var req_tracker: Dictionary
var tween: Tween
var time_left:float

var formatters = {
	"item": func(amt, item_name): return "%s x %s" % [item_name, amt],
	"location": func(val, _unused): return "Travel to %s" % val,
}

func _ready() -> void:
	# static
	name = "VBox_Action_%s" % data.action_id
	label_title.text = data.action_name
	
	reset_timer()
	
	for tag in data.tags:
		var new_tag = tag_scene.instantiate()
		new_tag.tag_name = tag
		hbox_tags.add_child(new_tag)

	generate_lists(true, data.req)
	generate_lists(false, data.rew)
	check_action_button()

func reset_timer():
	label_progress.text = format_time(data.time)
	button_action.text = data.action
	progress.value = 0

func format_time(time_in_seconds: float) -> String:
	var minutes = int(time_in_seconds) / 60
	var seconds = int(time_in_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]


func add_list_obj(req: bool, id: String, label: String):
	"""Creates req checkbox or rew label and adds to vBoxes"""
	if req:
		var new_check: CheckBox = CheckBox.new()
		new_check.mouse_filter = Control.MOUSE_FILTER_IGNORE
		new_check.text = label
		vbox_reqs.add_child(new_check)
		req_tracker[id] = new_check
		return new_check
	else:
		var new_label: Label = Label.new()
		new_label.text = label
		vbox_rews.add_child(new_label)

func generate_lists(req: bool, data_source: Array):	
	var pretty_name: String
	for entry in data_source:
		match entry["type"]:
			"item":
				pretty_name = Data.items[entry["id"]]["item_name"]
		add_list_obj(req, entry["id"], formatters[entry["type"]].call(pretty_name, entry.get("qty")))

func check_action_button():
	var forbidden = true
	var target = null
	for entry in data.req:
		match entry["type"]:
			"item":
				target = Player.inventory.get(entry["id"])
				if target != null and target["qty"] >= entry["qty"]:
					req_tracker[entry["id"]].button_pressed = true
					forbidden = false
				else:
					req_tracker[entry["id"]].button_pressed = false
					forbidden = true
	button_action.disabled = forbidden

func update_progress_label(current_time):
	var minutes = current_time / 60
	var seconds = current_time % 60
	label_progress.text = "%02d:%02d" % [minutes, seconds]

func _on_button_action_pressed() -> void:
	if tween and tween.is_running():
		print(tween.is_running())
		tween.kill()
		reset_timer()
	else:
		button_action.text = "Cancel"
		tween = create_tween().set_parallel(true)
		tween.tween_property(progress, "value", 100, data.time)
		tween.tween_method(update_progress_label, data.time, 1.0, data.time)
		tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	reset_timer()
	for entry in data.req:
		match entry["type"]:
			"item":
				SignalBus.remove_item.emit(entry["id"], entry["qty"])
	for entry in data.rew:
		match entry["type"]:
			"item":
				SignalBus.add_item.emit(entry["id"], entry["qty"])
	check_action_button()
