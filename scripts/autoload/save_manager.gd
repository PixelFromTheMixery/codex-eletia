extends Node

const SAVE_DIR: String = "user://.save/"
const DEV: bool = true
const PASS: String = "Codex-Eletia"
const SAVE_SLOT: String = "slot_1"
const SESSION: String = "1"
const WORLD: String = "world_" + SESSION
const FORMAT = ".json" if DEV else ".bin"
const SAVE_FILE_NAME = SAVE_DIR + SAVE_SLOT + FORMAT

var universe: Dictionary = {
	"world_1": { 
		"player": {},
		"world": {}
	}
}

func _ready():
	verify_save_directory()

func unmap_object(obj:Object):
	var obj_dict: Dictionary = {}
	var props = obj.get_property_list()
	for prop in props:
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			obj_dict[prop.name] = obj.get(prop.name)
	return obj_dict

func map_object(obj_dict: Dictionary, object_name: String):
	var target_obj = null
	match object_name:
		"player":
			target_obj = Player
		"world":
			target_obj = World
		_:
			print("Error: Target object not found for ", object_name)

	for key in obj_dict.keys():
		if key in target_obj:
			target_obj.set(key, obj_dict[key])
		else:
			print("Warning: Property ", key, " not found on ", object_name)

func verify_save_directory():
	"""Prepares file directory for interaction"""
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if not FileAccess.file_exists(SAVE_FILE_NAME):
		save_settings()
		save_session(true)
	else:
		load_data()

func load_data():
	universe = read_write(SAVE_FILE_NAME, "", true)
	map_object(universe[WORLD]["player"], "player")
	map_object(universe[WORLD]["world"], "world")

func save_player():
	universe[WORLD]["player"] = unmap_object(Player)
	read_write(SAVE_FILE_NAME, "Player Saved")

func save_world():
	universe[WORLD]["world"] = unmap_object(World)
	read_write(SAVE_FILE_NAME, "World Saved (literally)")

func save_session(initial: bool = false):
	"""Saves all game data at state"""
	universe[WORLD]["player"] = unmap_object(Player)
	universe[WORLD]["world"] = unmap_object(World)
	if initial:
		read_write(SAVE_FILE_NAME)
	else:
		read_write(SAVE_FILE_NAME, "Session Saved")

func save_settings():
	read_write(SAVE_DIR + "settings.json", "Settings Saved", unmap_object(Settings))

func read_write(path: String, save_message: String = "", read = false, data = universe):
	if read:
		if DEV or "settings" in path:
			var file = FileAccess.open(path, FileAccess.READ)
			return JSON.parse_string(file.get_as_text()) if file else {}
		else:
			var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, PASS)
			return file.get_var() if file else {}

	else:
		WorkerThreadPool.add_task(func():
			if DEV or "settings" in path:
				var file = FileAccess.open(path, FileAccess.WRITE)
				if file:
					file.store_string(JSON.stringify(data, "\t"))
			else:
				var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, PASS)
				if file:
					file.store_var(data)
		)
	if save_message != "":
		SignalBus.create_alert.emit.call_deferred(save_message)
