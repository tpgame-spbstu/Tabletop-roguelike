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
