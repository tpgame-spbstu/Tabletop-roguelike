extends Node


var player_1_health setget set_player_1_health
signal player_1_health_changed(player_1_health)
func set_player_1_health(new_value):
	player_1_health = new_value
	emit_signal("player_1_health_changed", player_1_health)


var player_2_health setget set_player_2_health
signal player_2_health_changed(player_2_health)
func set_player_2_health(new_value):
	player_2_health = new_value
	emit_signal("player_2_health_changed", player_2_health)


func reduse_enemy_health(attacker_number, delta):
	if attacker_number == 1:
		set_player_2_health(player_2_health - delta)
	else:
		set_player_1_health(player_1_health - delta)


var loop_number = 0 setget set_loop_number
signal loop_number_changed(loop_number)
func set_loop_number(new_value):
	loop_number = new_value
	emit_signal("loop_number_changed", loop_number)


enum TurnState {
	DRAW_CARDS,
	PLACE_AND_MOVE,
	ATTACK,
}
var turn_state
var active_player_number

signal player_1_draw_cards_enter()
signal player_1_place_and_move_enter()
signal player_1_attack_enter()
signal player_2_draw_cards_enter()
signal player_2_place_and_move_enter()
signal player_2_attack_enter()

func get_turn_state_signal(_turn_state, player_number):
	match _turn_state:
		TurnState.DRAW_CARDS:
			return "player_%d_draw_cards_enter" % player_number
		TurnState.PLACE_AND_MOVE:
			return "player_%d_place_and_move_enter" % player_number
		TurnState.ATTACK:
			return "player_%d_attack_enter" % player_number


func set_state(new_turn_state, new_active_player_number):
	assert(TurnState.values().has(new_turn_state))
	assert(new_active_player_number == 1 or new_active_player_number == 2)
	turn_state = new_turn_state
	active_player_number = new_active_player_number
	match turn_state:
		TurnState.DRAW_CARDS:
			emit_signal("player_%d_draw_cards_enter" % active_player_number)
		TurnState.PLACE_AND_MOVE:
			emit_signal("player_%d_place_and_move_enter" % active_player_number)
		TurnState.ATTACK:
			emit_signal("player_%d_attack_enter" % active_player_number)


func next_state():
	match turn_state:
		TurnState.DRAW_CARDS:
			set_state(TurnState.PLACE_AND_MOVE, active_player_number)
		TurnState.PLACE_AND_MOVE:
			set_state(TurnState.ATTACK, active_player_number)
		TurnState.ATTACK:
			var next_player = 2 if active_player_number == 1 else 1
			set_loop_number(loop_number + 1)
			set_state(TurnState.DRAW_CARDS, next_player)
