extends Spatial

# AIPlayer class - simple player with artificial intelligence 
#  who behaves according to a constant queue of moves

# A point to start play card animation from
onready var card_spawn_point := $card_spawn_point
onready var open_cards_enter_point := $open_cards_enter_point
onready var open_cards := $open_cards

signal show_card_description(card)

var board
var fight_state
var fight_global_signals

var player_number

# List of instruction of what card to play, when and where. Sorted by loop number
var card_queue = []
var prepared_cards = []

const MAX_PREPARED_CARDS_COUNT = 4

var TurnState := preload("res://Fight/fight_state.gd").TurnState
var CardConfig := preload("res://Card/card_config.gd")
var Card := preload("res://Card/card.tscn")


# Set up exturnal nodes, connect state change signals and load card queue from params
func initialize(fight_state, fight_global_signals, board, deck_config, player_number, params):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.player_number = player_number
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, fight_state.get_enemy_number(player_number)), 
		self, "_on_enemy_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, player_number), 
		self, "_on_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.PLACE_AND_MOVE, player_number), 
		self, "_on_place_and_move_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.ATTACK, player_number), 
		self, "_on_attack_enter")
	card_queue = params["ai_card_queue"].duplicate()


# Show prepared cards to player
func _on_enemy_draw_cards_enter():
	prepare_cards()


# AI do not need to draw cards for now
func _on_draw_cards_enter():
	fight_state.next_state()


# First place new cards, then move all cards (wait for animations)
func _on_place_and_move_enter():
	var temp_state = place_cards()
	if temp_state != null:
		yield(temp_state, "completed")
	temp_state = move_cards()
	if temp_state != null:
		yield(temp_state, "completed")
	fight_state.next_state()


# Play card to board cell, with lin animation to board_cell
func play_card(board_cell, card_to_play):
	# Temporary remove card from open_cards and add to player root
	var card_trans = $open_cards.remove_card(card_to_play)
	add_child(card_to_play)
	
	# Play animation
	var animation = SmoothMoveAnimation.new(card_trans, 
		board_cell.global_transform, 0.4, card_to_play)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	
	# Remove empty hand cell
	$open_cards.remove_empty()
	
	# Add to target cell
	self.remove_child(card_to_play)
	board_cell.add_card(card_to_play)
	
	# Emit global signal
	fight_global_signals.emit_signal("card_played", board_cell, card_to_play)


func prepare_cards():
	var i = 0
	while (prepared_cards.size() < MAX_PREPARED_CARDS_COUNT 
		and i < card_queue.size()):
		var new_column_index = card_queue[i].column_index
		var is_taken = false
		for prepared_card in prepared_cards:
			if prepared_card["queue_item"].column_index == new_column_index:
				is_taken = true
				break
		if is_taken:
			i += 1
			continue
		yield(_add_prepared_card(card_queue[i]), "completed")
		card_queue.remove(i)


func _add_prepared_card(queue_item):
	var card = Card.instance()
	
	add_child(card)
	card.initialize(queue_item.card_config, player_number, fight_global_signals, fight_state)
	
	# Play animation
	var animation = SmoothMoveAnimation.new(card_spawn_point.global_transform, 
		open_cards_enter_point.global_transform, 0.2, card)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	
	# Add to open_cards
	self.remove_child(card)
	$open_cards.add_card(card)
	
	prepared_cards.append({"card": card, "queue_item": queue_item})


func place_cards():
	var i = 0
	# Get index of player's base row
	var base_row_index = board.get_friendly_base_row_index(player_number)
	
	# Trying to play cards in queue, when it is time to do it
	while i < prepared_cards.size():
		var queue_item = prepared_cards[i]["queue_item"]
		var card = prepared_cards[i]["card"]
		# Get board cell to place new card to it
		var target_cell = board.get_board_cell(base_row_index, queue_item.column_index)
		if target_cell.get_card_or_null() == null and queue_item.loop_number <= fight_state.loop_number:
			# Board cell is empty - play prepared card
			# Wait for animation
			yield(play_card(target_cell, card), "completed")
			# Remove from queue
			prepared_cards.remove(i)
		else:
			# Board cell is full or to early - go to next queue item
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
	var temp_state = board.process_player_attack(player_number)
	if temp_state != null:
		yield(temp_state, "completed")
	fight_state.next_state()


func _on_open_cards_card_right_click(card):
	emit_signal("show_card_description", card)
