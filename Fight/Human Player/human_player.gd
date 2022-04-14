extends Spatial

onready var selector := $selector
onready var hand := $hand
onready var main_deck := $main_deck
onready var dummy_deck := $dummy_deck
onready var human_player_state := $human_player_state

var board
var fight_state
var fight_global_signals
var player_number

var input_allowed := true

var TurnState := preload("res://Fight/fight_state.gd").TurnState

func initialize(fight_state, fight_global_signals, board, bell, deck_config, player_number, params):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.player_number = player_number
	board.connect("board_left_click", self, "_on_board_left_click")
	hand.connect("hand_left_click", self, "_on_left_hand_click")
	main_deck.initialize(fight_global_signals, deck_config, params["shuffle_seed"], player_number)
	main_deck.connect("deck_click", self, "_on_deck_click")
	dummy_deck.initialize(fight_global_signals, null, null, player_number)
	dummy_deck.connect("deck_click", self, "_on_deck_click")
	bell.connect("bell_click", self, "_on_bell_click")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, player_number), 
		self, "_on_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.PLACE_AND_MOVE, player_number), 
		self, "_on_place_and_move_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.ATTACK, player_number), 
		self, "_on_attack_enter")
	

func _on_draw_cards_enter():
	human_player_state.restore_energy(fight_state.loop_number)
	human_player_state.card_to_play = null
	human_player_state.card_to_move = null


func _on_place_and_move_enter():
	human_player_state.set_extra_draws_count(1)


func _on_attack_enter():
	board._on_attack_enter(fight_state, player_number)
	fight_state.next_state()


func _on_board_left_click(board_cell, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		return
	if fight_state.turn_state != TurnState.PLACE_AND_MOVE:
		return
	if human_player_state.card_to_play != null:
		if card != null:
			return
		if !board_cell.is_friendly_base(player_number):
			return
		var card_to_play = human_player_state.card_to_play
		card_to_play.card_config.play_cost.pay(human_player_state)
		hand.remove_card(card_to_play.get_hand_cell_or_null(), card_to_play)
		self.add_child(card_to_play)
		input_allowed = false
		yield(board.play_card(hand, board_cell, card_to_play), "completed")
		input_allowed = true
		human_player_state.card_to_play = null
		selector.set_state("hide")
	elif human_player_state.card_to_move != null:
		if card == human_player_state.card_to_move:
			human_player_state.card_to_move = null
			selector.set_state("hide")
			return
		var move_cost = human_player_state.card_to_move.get_move_cost_or_null(board_cell)
		if move_cost == null:
			return
		if !move_cost.is_obtainable(human_player_state):
			return
		move_cost.pay(human_player_state)
		input_allowed = false
		yield(board.move_card(board_cell, human_player_state.card_to_move), "completed")
		input_allowed = true
		human_player_state.card_to_move = null
		selector.set_state("hide")
	else:
		if card == null:
			return
		if card.owner_number != player_number:
			return
		human_player_state.card_to_move = card
		selector.move_to(board_cell)
		selector.set_state("move")




func _on_left_hand_click(hand_cell, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		return
	if fight_state.turn_state != TurnState.PLACE_AND_MOVE:
		return
	if human_player_state.card_to_play != null:
		human_player_state.card_to_play = null
		selector.set_state("hide")
	elif human_player_state.card_to_move != null:
		human_player_state.card_to_move = null
		selector.set_state("hide")
	else:
		if !card.card_config.play_cost.is_obtainable(human_player_state):
			return
		human_player_state.card_to_play = card
		selector.move_to(hand_cell)
		selector.set_state("card_to_play")


func _on_deck_click(deck, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		return
	match fight_state.turn_state:
		TurnState.DRAW_CARDS:
			if card == null:
				fight_state.reduse_player_health(player_number, 1)
			else:
				yield(draw_card(deck, card), "completed")
			fight_state.next_state()
		TurnState.PLACE_AND_MOVE:
			if card == null:
				return
			if human_player_state.extra_draw_cost.is_obtainable(human_player_state) && human_player_state.extra_draws_count > 0:
				human_player_state.extra_draw_cost.pay(human_player_state)
				human_player_state.extra_draws_count -= 1
				yield(draw_card(deck, card), "completed")


func draw_card(deck, card):
	var animation = LinMoveAnimation.new(deck.global_transform,
		hand.global_transform, 0.1, card)
	AnimationManager.add_animation(animation)
	input_allowed = false
	yield(animation, "animation_ended")
	input_allowed = true
	card.get_parent().remove_child(card)
	hand.add_card(card)


func _on_bell_click(bell):
	print("bell")
	selector.set_state("hide")
	if fight_state.active_player_number != player_number:
		return
	if fight_state.turn_state == TurnState.PLACE_AND_MOVE:
		fight_state.next_state()

