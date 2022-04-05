extends Reference


enum State {
	PLAYER_DRAW_CARDS,
	PLAYER_PLACE_AND_MOVE,
	PLAYER_ATTACK,
	AI_DRAW_CARDS,
	AI_PLACE_AND_MOVE,
	AI_ATTACK,
}

var player_health setget set_player_health
var ai_health setget set_ai_health

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

signal player_draw_cards_enter()
signal player_place_and_move_enter()
signal player_attack_enter()
signal ai_draw_cards_enter()
signal ai_place_and_move_enter()
signal ai_attack_enter()

func set_state(new_value):
	assert(State.values().has(new_value))
	state = new_value
	match state:
		State.PLAYER_DRAW_CARDS:
			print("Changed state to PLAYER_DRAW_CARDS")
			emit_signal("player_draw_cards_enter")
		State.PLAYER_PLACE_AND_MOVE:
			set_extra_draws_count(1)
			print("Changed state to PLAYER_PLACE_AND_MOVE")
			emit_signal("player_place_and_move_enter")
		State.PLAYER_ATTACK:
			print("Changed state to PLAYER_ATTACK")
			emit_signal("player_attack_enter")
		State.AI_DRAW_CARDS:
			print("Changed state to AI_DRAW_CARDS")
			emit_signal("ai_draw_cards_enter")
		State.AI_PLACE_AND_MOVE:
			print("Changed state to AI_PLACE_AND_MOVE")
			emit_signal("ai_place_and_move_enter")
		State.AI_ATTACK:
			print("Changed state to AI_ATTACK")
			emit_signal("ai_attack_enter")


func next_state():
	match state:
		State.PLAYER_DRAW_CARDS:
			set_state(State.PLAYER_PLACE_AND_MOVE)
		State.PLAYER_PLACE_AND_MOVE:
			set_state(State.PLAYER_ATTACK)
		State.PLAYER_ATTACK:
			set_state(State.AI_DRAW_CARDS)
		State.AI_DRAW_CARDS:
			set_state(State.AI_PLACE_AND_MOVE)
		State.AI_PLACE_AND_MOVE:
			set_state(State.AI_ATTACK)
		State.AI_ATTACK:
			set_loop_number(loop_number + 1)
			set_state(State.PLAYER_DRAW_CARDS)


func set_energy(new_value):
	energy = new_value
	print("Energy changet to %d" % energy)


func set_bones(new_value):
	bones = new_value
	print("Bones changet to %d" % bones)


func set_player_health(new_value):
	bones = new_value
	print("player_health changet to %d" % player_health)


func set_ai_health(new_value):
	ai_health = new_value
	print("ai_health changet to %d" % ai_health)


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
	set_state(State.PLAYER_DRAW_CARDS)
