extends Node


class InputRequest:
	var type: String
	var data: Dictionary
	var is_allowed: bool
	
	
	func allow():
		is_allowed = true
	
	
	func _init(type, data):
		self.type = type
		self.data = data
		self.is_allowed = false


var fight_state


func initialize(fight_state, player_1):
	self.fight_state = fight_state
	player_1.connect("input_requested", self, "_on_input_requested")


func _on_input_requested(input_request: InputRequest):
	input_request.allow()
