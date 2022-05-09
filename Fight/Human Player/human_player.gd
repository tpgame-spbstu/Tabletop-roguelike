extends Spatial

# HumanPlayer class - a player, controled by human inputs

onready var selector := $selector
onready var hand := $hand
onready var bell := $gong
onready var main_deck := $main_deck
onready var dummy_deck := $dummy_deck
onready var human_player_state := $human_player_state
onready var turn_end_pause_timer := $turn_end_pause_timer
const TURN_END_PAUSE_TIME = 0.5

signal card_to_play_selected(card)

var board
var fight_state
var fight_global_signals
var player_number

var input_allowed := true

var TurnState := preload("res://Fight/fight_state.gd").TurnState

func initialize(fight_state, fight_global_signals, board, deck_config, player_number, params):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.player_number = player_number
	
	board.connect("board_left_click", self, "_on_board_left_click")
	
	hand.connect("hand_left_click", self, "_on_hand_left_click")
	
	main_deck.initialize(fight_global_signals, fight_state, deck_config, params["shuffle_seed"], player_number)
	main_deck.connect("deck_click", self, "_on_deck_click")
	
	dummy_deck.initialize(fight_global_signals, fight_state, null, null, player_number)
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
	highlight_possible_moves()


func _on_place_and_move_enter():
	# Give option to draw one more card for energy cost
	human_player_state.set_extra_draws_count(1)
	human_player_state.card_to_play = null
	human_player_state.card_to_move = null
	highlight_possible_moves()


func _on_attack_enter():
	# Give all cards a chance to attack
	input_allowed = false
	var tmp_state = board.process_player_attack(player_number)
	if tmp_state != null:
		yield(tmp_state, "completed")
	turn_end_pause_timer.start(TURN_END_PAUSE_TIME)
	yield(turn_end_pause_timer, "timeout")
	input_allowed = true
	fight_state.next_state()


# Play card to board cell, with lin animation from hand to board_cell
func play_card(board_cell, card_to_play):
	
	# Temporary remove card from hand_cell and add to player root
	var card_trans = hand.remove_card(card_to_play)
	add_child(card_to_play)

	# Play animation
	var animation = LinMoveAnimation.new(card_trans, 
		board_cell.global_transform, 0.2, card_to_play)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	
	# Add to target cell
	self.remove_child(card_to_play)
	board_cell.add_card(card_to_play)
	
	# Emit global signal
	fight_global_signals.emit_signal("card_played", board_cell, card_to_play)


func _on_board_left_click(board_cell, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		# other player's turn
		return
	if fight_state.turn_state != TurnState.PLACE_AND_MOVE:
		# PLACE_AND_MOVE not allowed
		return
	cancel_highlight()
	if human_player_state.card_to_play != null:
		# Selected card to play
		if card != null:
			# cell not empty, can't play card, so clear selection
			cancel_selection()
			return
		if !board_cell.is_friendly_base(player_number):
			# cell not a friendly base, can't play
			return
		var card_to_play = human_player_state.card_to_play
		# Pay cost for card
		card_to_play.card_config.play_cost.pay(human_player_state)
		# Play selected card
		input_allowed = false
		yield(play_card(board_cell, card_to_play), "completed")
		input_allowed = true
		# Reset selected card
		cancel_selection()
		highlight_possible_moves()
	elif human_player_state.card_to_move != null:
		# Selected card to move
		if card == human_player_state.card_to_move:
			# clicked on selected card, reset selection
			human_player_state.card_to_move = null
			selector.set_state("hide")
			highlight_possible_moves()
			return
		var move_cost = human_player_state.card_to_move.get_move_cost_or_null(board_cell)
		if move_cost == null:
			cancel_selection()
			# Can't move card
			highlight_possible_moves()
			return
		if !move_cost.is_obtainable(human_player_state):
			cancel_selection()
			# Can't pay cost
			highlight_possible_moves()
			return
		# Pay cost to move
		move_cost.pay(human_player_state)
		# Move card
		input_allowed = false
		yield(board.move_card(board_cell, human_player_state.card_to_move), "completed")
		input_allowed = true
		# Reset selected card
		cancel_selection()
		highlight_possible_moves()
	else:
		# No selected cards
		if card == null:
			# Cell is empty
			return
		if card.owner_number != player_number:
			# Clicked on enemy card
			return
		# Select card to move
		human_player_state.card_to_move = card
		cancel_highlight()
		highlight_possible_card_moves(board_cell)
		selector.move_to(board_cell)
		selector.set_state("move")


func _on_hand_left_click(hand_cell, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		# other player's turn
		return
	cancel_highlight()
	if fight_state.turn_state != TurnState.PLACE_AND_MOVE:
		# PLACE_AND_MOVE not allowed
		return
		cancel_highlight()
	if human_player_state.card_to_play != null:
		# Selected card to play
		# Reset selected card
		cancel_selection()
	elif human_player_state.card_to_move != null:
		# Selected card to move
		# Reset selected card
		cancel_selection()
	else:
		# No selected cards
		if !card.card_config.play_cost.is_obtainable(human_player_state):
			# Can't pay for card
			return
		# Select card to play
		emit_signal("card_to_play_selected", card)
		human_player_state.card_to_play = card
		selector.move_to(hand_cell)
		selector.set_state("card_to_play")
		cancel_highlight()
		highlight_empty_base_fields()


func _on_deck_click(deck, card):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		# other player's turn
		return
	cancel_selection()
	match fight_state.turn_state:
		TurnState.DRAW_CARDS:
			# State DRAW_CARDS
			if card == null:
				# Clicked on empty deck
				# Get damage
				fight_state.reduce_player_health(player_number, 1)
			else:
				# Draw card from deck
				yield(draw_card(deck, card), "completed")
			fight_state.next_state()
			highlight_possible_moves()
		TurnState.PLACE_AND_MOVE:
			cancel_highlight()
			# State PLACE_AND_MOVE
			if card == null:
				# Clicked on empty deck
				return
			if human_player_state.extra_draw_cost.is_obtainable(human_player_state) && human_player_state.extra_draws_count > 0:
				# Can draw extra card and can pay cost
				# Pay for extra draw
				human_player_state.extra_draw_cost.pay(human_player_state)
				human_player_state.extra_draws_count -= 1
				# Draw card from deck
				yield(draw_card(deck, card), "completed")
				highlight_possible_moves()


# Draw card from deck
func draw_card(deck, card):
	deck.remove_card(card)
	var dest = hand.add_card(card, false)
	dest = Transform(Basis(Vector3(0, dest[1], 0)), dest[0] + hand.get_global_transform().origin)
	var animation = LinMoveAnimation.new(deck.global_transform,
		dest, 0.2, card)
	AnimationManager.add_animation(animation)
	input_allowed = false
	yield(animation, "animation_ended")
	input_allowed = true

	hand.draw_cards()
	card.set_global_transform(hand._proxies[~0].get_global_transform())
	card.global_rotate(Vector3.UP, -PI)


func _on_bell_click(bell):
	if !input_allowed:
		return
	if fight_state.active_player_number != player_number:
		# if other player's turn
		return
	if fight_state.turn_state == TurnState.PLACE_AND_MOVE:
		# Go to attack when PLACE_AND_MOVE finished
		cancel_selection()
		input_allowed = false
		yield(bell.play_hit_animation(), "completed")
		input_allowed = true
		fight_state.next_state()


func highlight_empty_base_fields():
	var base_index = board.get_friendly_base_row_index(player_number)
	var cell
	for i in range(board.column_count):
		cell = board.get_board_cell(base_index, i)
		if cell.get_card_or_null() == null:
			cell.highlight()
			
	
	
func highlight_possible_card_moves(board_cell):
	var row = board_cell.row_index
	var col = board_cell.column_index
	var cells_to_highlight = []
	var card = board_cell.get_card_or_null()
	assert(card != null)

	cells_to_highlight.append(board.get_board_cell(row + 1, col))
	cells_to_highlight.append(board.get_board_cell(row - 1, col))
	cells_to_highlight.append(board.get_board_cell(row, col + 1))
	cells_to_highlight.append(board.get_board_cell(row, col - 1))
	
	for i in cells_to_highlight:
		if i != null and typeof(i) != TYPE_INT:
			var move_cost = card.get_move_cost_or_null(i)
			if move_cost != null and move_cost.is_obtainable(human_player_state):
				i.highlight()


func cancel_highlight():
	board.cancel_highlight()
	highlight_possible_moves()


func cancel_selection():
	#removes selection and cancels highlight
	selector.set_state("hide")
	human_player_state.cancel_selection()
	cancel_highlight()


func highlight_possible_moves():
	#hand
	if human_player_state.card_to_move != null or human_player_state.card_to_play != null:
		hand.cancel_highlight()
		dummy_deck.cancel_highlight()
		main_deck.cancel_highlight()
		return
	
	var is_obtainable = hand.has_obtainable_cards(human_player_state)
	var is_free_space = board.has_free_base_cells(player_number)
	var has_playable_cards = false
	if(is_obtainable and is_free_space and fight_state.turn_state == TurnState.PLACE_AND_MOVE 
	and fight_state.active_player_number == player_number):
		hand.highlight()
		has_playable_cards = true
	else:
		hand.cancel_highlight()
	
	#deck
	var is_drawable = false
	if fight_state.turn_state == TurnState.DRAW_CARDS or human_player_state.extra_draw_cost.is_obtainable(human_player_state) and human_player_state.extra_draws_count > 0:
		if dummy_deck.get_card_count() > 0:
			dummy_deck.highlight()
		else:
			dummy_deck.cancel_highlight()
			
		if main_deck.get_card_count() > 0:
			main_deck.highlight()
		else:
			main_deck.cancel_highlight()
		is_drawable = true
	else:
		dummy_deck.cancel_highlight()
		main_deck.cancel_highlight()
	
	#board
	var is_movable = false
	
	if (fight_state.turn_state == TurnState.PLACE_AND_MOVE):
		board.cancel_highlight()
		for i in range(board.rows_count):
			for j in range(board.column_count):
				var cell = board.get_board_cell(i, j)
				var card = cell.get_card_or_null()
				if card == null or card.owner_number != player_number:
					continue
				var neighbours = board.get_cell_neighbours(cell)
				if neighbours != null:
					for n in neighbours:
						if n!=null and n.get_card_or_null() == null:
							var move_cost = card.get_move_cost_or_null(n)
							if move_cost == null:
								continue
							if move_cost.is_obtainable(human_player_state):
								cell.highlight()
