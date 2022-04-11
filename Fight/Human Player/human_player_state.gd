extends Node


var energy setget set_energy
signal energy_changed(energy)
func set_energy(new_value):
	energy = new_value
	emit_signal("energy_changed", energy)
	
var bones setget set_bones
signal bones_changed(bones)
func set_bones(new_value):
	bones = new_value
	emit_signal("bones_changed", bones)


var extra_draws_count setget set_extra_draws_count
signal extra_draws_count_changed(extra_draws_count)
func set_extra_draws_count(new_value):
	extra_draws_count = new_value
	emit_signal("extra_draws_count_changed", extra_draws_count)


var extra_draw_cost = Cost.new(2, 0, 0)

var card_to_play
var card_to_move

var max_energy_for_loop = [ 0, 2, 3, 4, 5, 6, 7 ]


func restore_energy(loop_number):
	if loop_number < max_energy_for_loop.size():
		set_energy(max_energy_for_loop[loop_number])
	else:
		set_energy(max_energy_for_loop.back())


