extends Node

var logs: Dictionary = {
	"Debug" : true,
	"Loot": true
}
var general: Dictionary = {
	"Alert Timeout" : 3
}

func save():
	Save.save_settings()
