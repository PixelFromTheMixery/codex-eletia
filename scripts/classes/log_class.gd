extends Resource

class_name LogData

var log_type: String
var content: String

func _init(new_log_type: String, new_content: String):
	"""Applies data on instantiation"""
	self.log_type = new_log_type
	self.content = new_content
