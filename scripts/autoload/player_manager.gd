extends Node

@export var inventory: Dictionary = {
	"TestItem": {"qty": 1}
}

@export var reputation: Dictionary = {
	"world": 0
}

@export var upgrades: Dictionary = {
}

var max_weight: int = 50
var current_weight: float = 0
