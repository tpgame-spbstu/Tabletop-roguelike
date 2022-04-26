extends Spatial

# AIPlayer class - simple player with artificial intelligence 
#  who behaves according to a constant queue of moves

# A point to start play card animation from
onready var card_spawn_point := $card_spawn_point

var board
var fight_state
var fight_global_signals

var player_number

# List of instruction of what card to play, when and where. Sorted by loop number
var card_queue = []

var TurnState := preload("res://Fight/fight_state.gd").TurnState
var CardConfig := preload("res://Card/card_config.gd")
var Card := preload("res://Card/card.tscn")


# Set up exturnal nodes, connect state change signals and load card queue from params
func initialize(fight_state, fight_global_signals, board, player_number, params):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.player_number = player_number
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, player_number), 
		self, "_on_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.PLACE_AND_MOVE, player_number), 
		self, "_on_place_and_move_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.ATTACK, player_number), 
		self, "_on_attack_enter")
	card_queue = params["ai_card_queue"].duplicate()


# AI do not need to draw cards for now
func _on_draw_cards_enter():
	fight_state.next_state()


# First place new cards, then move all cards (wait for animations)
func _on_place_and_move_enter():
	var res = place_cards()
	if res != null:
		yield(res, "completed")
	res = move_cards()
	if res != null:
		yield(res, "completed")
	fight_state.next_state()


func place_cards():
	var i = 0
	# Get index of player's base row
	var base_row_index = board.get_friendly_base_row_index(player_number)
	
	# Trying to play cards in queue, when it is time to do it
	while i < card_queue.size() and card_queue[i].loop_number <= fight_state.loop_number:
		# Get board cell to place new card to it
		var target_cell = board.get_board_cell(base_row_index, card_queue[i].column_index)
		if target_cell.get_card_or_null() == null:
			# Board cell is empty - create new card
			var card_to_play = Card.instance()
			card_spawn_point.add_child(card_to_play)
			card_to_play.initialize(card_queue[i].card_config, player_number, fight_global_signals, fight_state)
			# Wait for animation
			yield(board.play_card(card_spawn_point, target_cell, card_to_play), "completed")
			# Remove from queue
			card_queue.remove(i)
		else:
			# Board cell is full - go to next queue item
			i += 1


func move_cards():
	# Iterate board:
	for column_index in range(board.column_count):
		for row_index in range(board.rows_count):
			var cell = board.get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != player_number:
				# board cell is empty or other player's card
				continue
			# Try to move id the attack direction
			var target_cell = cell.get_relative_board_cell(card.player_attack_direction[player_number], 0)
			var move_cost = card.get_move_cost_or_null(target_cell)
			if move_cost == null:
				# Can't move
				continue
			# Move card and wait for animation
			yield(board.move_card(target_cell, card), "completed")


func _on_attack_enter():
	# Give all cards a chance to attack
	board.process_player_attack(player_number)
	fight_state.next_state()
