extends Reference


enum State {
	PLAYER_1_DRAW_CARDS,
	PLAYER_1_PLACE_AND_MOVE,
	PLAYER_1_ATTACK,
	PLAYER_2_DRAW_CARDS,
	PLAYER_2_PLACE_AND_MOVE,
	PLAYER_2_ATTACK,
}

var player_1_health setget set_player_1_health
var player_2_health setget set_player_2_health

var loop_number = 0 setget set_loop_number
var state setget set_state
var energy setget set_energy
var bones setget set_bones
var extra_draws_count setget set_extra_draws_count

var card_to_play
var card_to_move

var max_energy_for_loop = [ 0, 2, 3, 4, 5, 6, 7 ]


func set_loop_number(new_value):
	loop_number = new_value
	print("Loop number %d" % loop_number)

signal player_1_draw_cards_enter()
signal player_1_place_and_move_enter()
signal player_1_attack_enter()
signal player_2_draw_cards_enter()
signal player_2_place_and_move_enter()
signal player_2_attack_enter()

func set_state(new_value):
	assert(State.values().has(new_value))
	state = new_value
	match state:
		State.PLAYER_1_DRAW_CARDS:
			print("Changed state to PLAYER_1_DRAW_CARDS")
			emit_signal("player_1_draw_cards_enter")
		State.PLAYER_1_PLACE_AND_MOVE:
			print("Changed state to PLAYER_PLACE_AND_MOVE")
			emit_signal("player_1_place_and_move_enter")
		State.PLAYER_1_ATTACK:
			print("Changed state to PLAYER_ATTACK")
			emit_signal("player_1_attack_enter")
		State.PLAYER_2_DRAW_CARDS:
			print("Changed state to PLAYER_2_DRAW_CARDS")
			emit_signal("player_2_draw_cards_enter")
		State.PLAYER_2_PLACE_AND_MOVE:
			print("Changed state to PLAYER_2_PLACE_AND_MOVE")
			emit_signal("player_2_place_and_move_enter")
		State.PLAYER_2_ATTACK:
			print("Changed state to PLAYER_2_ATTACK")
			emit_signal("player_2_attack_enter")


func next_state():
	match state:
		State.PLAYER_1_DRAW_CARDS:
			set_state(State.PLAYER_1_PLACE_AND_MOVE)
		State.PLAYER_1_PLACE_AND_MOVE:
			set_state(State.PLAYER_1_ATTACK)
		State.PLAYER_1_ATTACK:
			set_state(State.PLAYER_2_DRAW_CARDS)
		State.PLAYER_2_DRAW_CARDS:
			set_state(State.PLAYER_2_PLACE_AND_MOVE)
		State.PLAYER_2_PLACE_AND_MOVE:
			set_state(State.PLAYER_2_ATTACK)
		State.PLAYER_2_ATTACK:
			set_loop_number(loop_number + 1)
			set_state(State.PLAYER_1_DRAW_CARDS)


func set_energy(new_value):
	energy = new_value
	print("Energy changet to %d" % energy)


func set_bones(new_value):
	bones = new_value
	print("Bones changet to %d" % bones)


func set_player_1_health(new_value):
	player_1_health = new_value
	print("player_1_health changet to %d" % player_1_health)


func set_player_2_health(new_value):
	player_2_health = new_value
	print("player_2_health changet to %d" % player_2_health)


func restore_energy():
	if loop_number < max_energy_for_loop.size():
		set_energy(max_energy_for_loop[loop_number])
	else:
		set_energy(max_energy_for_loop.back())


func set_extra_draws_count(new_value):
	extra_draws_count = new_value
	print("extra_draws_count changet to %d" % extra_draws_count)


func start():
	set_loop_number(1)
	set_player_1_health(5)
	set_player_2_health(5)
	set_state(State.PLAYER_1_DRAW_CARDS)
