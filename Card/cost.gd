extends Reference

class_name Cost

# Cost class - base class for cost information

var energy : int
var bones : int
var blood : int


func _init(energy : int, bones : int, blood : int):
	self.energy = energy
	self.bones = bones
	self.blood = blood


# Check if player can pay this cost
func is_obtainable(human_player_state):
	return human_player_state.energy >= energy


# Process payment
func pay(human_player_state):
	human_player_state.energy -= energy


# Get copy of this object
func get_copy():
	return get_script().new(energy, bones, blood)
