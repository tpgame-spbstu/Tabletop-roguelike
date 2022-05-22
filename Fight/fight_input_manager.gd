extends Node


class InputRequest:
	var type: String
	var data: Dictionary
	var is_allowed: bool
	
	
	func allow():
		is_allowed = true
	
	
	func _init(type, data= {}):
		self.type = type
		self.data = data
		self.is_allowed = false


var fight_state
var fight_global_signals
var board
var human_player


func initialize(fight_state, fight_global_signals, board, human_player):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.human_player = human_player
	human_player.connect("input_requested", self, "_on_input_requested")


func _on_input_requested(input_request: InputRequest):
	input_request.allow()
