extends Spatial

onready var selector := $selector
onready var hand := $hand
onready var deck := $deck
onready var human_player_state := $human_player_state

var board
var fight_state
var player_number

var input_allowed := true

var TurnState := preload("res://Fight/fight_state.gd").TurnState

func initialize(fight_state, board, bell, deck_config, player_number, params):
	self.fight_state = fight_state
	self.board = board
	self.player_number = player_number
	board.connect("board_click", self, "_on_board_click")
	hand.connect("hand_click", self, "_on_hand_click")
	deck.initialize(deck_config, params["shuffle_seed"], player_number)
	deck.connect("deck_click", self, "_on_deck_click")
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


func _on_board_click(board_cell, card):
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
		human_player_state.card_to_play.play_cost.pay(human_player_state)
		yield(play_card(board_cell, human_player_state.card_to_play), "completed")
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
		yield(move_card(board_cell, human_player_state.card_to_move), "completed")
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


func move_card(board_cell, card_to_move):
	var prev_board_cell = card_to_move.get_board_cell_or_null()
	assert(prev_board_cell != null)
	card_to_move.animation = LinMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.1, card_to_move)
	input_allowed = false
	yield(card_to_move, "animation_ended")
	input_allowed = true
	prev_board_cell.remove_card(card_to_move)
	board_cell.add_card(card_to_move)


func play_card(board_cell, card_to_play):
	var hand_cell = card_to_play.get_hand_cell_or_null()
	assert(hand_cell != null)
	card_to_play.animation = LinMoveAnimation.new(hand_cell.global_transform, 
		board_cell.global_transform, 0.1, card_to_play)
	input_allowed = false
	yield(card_to_play, "animation_ended")
	input_allowed = true
	hand.remove_card(hand_cell, card_to_play)
	board_cell.add_card(card_to_play)


func _on_hand_click(hand_cell, card):
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
		if !card.play_cost.is_obtainable(human_player_state):
			return
		human_player_state.card_to_play = card
		selector.move_to(hand_cell)
		selector.set_state("card_to_play")


func _on_deck_click(deck, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		return
	if card == null:
		return
	match fight_state.turn_state:
		TurnState.DRAW_CARDS:
			yield(draw_card(deck, card), "completed")
			fight_state.next_state()
		TurnState.PLACE_AND_MOVE:
			if human_player_state.extra_draw_cost.is_obtainable(human_player_state) && human_player_state.extra_draws_count > 0:
				human_player_state.extra_draw_cost.pay(human_player_state)
				human_player_state.extra_draws_count -= 1
				draw_card(deck, card)


func draw_card(deck, card):
	card.animation = LinMoveAnimation.new(deck.global_transform,
		hand.global_transform, 0.1, card)
	input_allowed = false
	yield(card, "animation_ended")
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

