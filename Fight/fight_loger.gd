extends Node

func _on_fight_state_player_1_health_changed(player_1_health):
	print("player_1_health changed to %d" % player_1_health)


func _on_fight_state_player_2_health_changed(player_2_health):
	print("player_2_health changed to %d" % player_2_health)


func _on_fight_state_loop_number_changed(loop_number):
	print("Loop number %d" % loop_number)


func _on_fight_state_player_1_draw_cards_enter():
	print("Changed state to PLAYER_1_DRAW_CARDS")


func _on_fight_state_player_1_place_and_move_enter():
	print("Changed state to PLAYER_1_PLACE_AND_MOVE")


func _on_fight_state_player_1_attack_enter():
	print("Changed state to PLAYER_1_ATTACK")


func _on_fight_state_player_2_draw_cards_enter():
	print("Changed state to PLAYER_2_DRAW_CARDS")


func _on_fight_state_player_2_place_and_move_enter():
	print("Changed state to PLAYER_2_PLACE_AND_MOVE")


func _on_fight_state_player_2_attack_enter():
	print("Changed state to PLAYER_2_ATTACK")


func _on_human_player_state_energy_changed(energy):
	print("Energy changed to %d" % energy)


func _on_human_player_state_bones_changed(bones):
	print("Bones changed to %d" % bones)


func _on_human_player_state_extra_draws_count_changed(extra_draws_count):
	print("extra_draws_count changed to %d" % extra_draws_count)


func _on_fight_state_player_1_win_enter():
	print("player_1_win")


func _on_fight_state_player_2_win_enter():
	print("player_2_win")
