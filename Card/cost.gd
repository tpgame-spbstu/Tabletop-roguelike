extends Reference

class_name Cost

var energy : int
var bones : int
var blood : int

func _init(energy : int, bones : int, blood : int):
	self.energy = energy
	self.bones = bones
	self.blood = blood

func is_obtainable(human_player_state):
	return human_player_state.energy >= energy

func pay(human_player_state):
	human_player_state.energy -= energy

func get_copy():
	return get_script().new(energy, bones, blood)
