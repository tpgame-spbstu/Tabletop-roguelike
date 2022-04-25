extends Spatial

var rows_count
var column_count

var fight_global_signals
signal board_left_click(board_cell, card)
signal board_right_click(board_cell, card)


# Set up exturnal nodes, initialize and connect cells
func initialize(fight_global_signals):
	
	self.fight_global_signals = fight_global_signals
	rows_count = get_child_count()
	column_count = get_child(0).get_child_count()
	for row_index in range(rows_count):
		for column_index in range(column_count):
			var cell = get_board_cell(row_index, column_index)
			cell.initialize(self, row_index, column_index)
			cell.connect("input_event", self, "_on_board_cell_input_event")


func get_board_cell(row_index, column_index):
	if column_index < 0 or column_index >= column_count:
		# Column index out of bounds
		return null
	if row_index < 0:
		# Not a cell, but base of player 1
		return 1
	if row_index >= rows_count:
		# Not a cell, but base of player 2
		return 2
	# Correct cell indexes
	return get_child(row_index).get_child(column_index)


# Get row index of current player's base
func get_friendly_base_row_index(player_number):
	if player_number == 1:
		return 0
	else:
		return 3


# Get row index of other player's base
func get_enemy_base_row_index(player_number):
	if player_number == 1:
		return 3
	else:
		return 0


func _on_board_cell_input_event(board_cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			# Left click on board cell
			emit_signal("board_left_click", board_cell, board_cell.get_card_or_null())
		elif mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_RIGHT :
			# Right click on board cell
			emit_signal("board_right_click", board_cell, board_cell.get_card_or_null())


# Give a chance to attack to all player's cards in right order
func process_player_attack(player_number):
	if player_number == 1:
		player_1_attack()
	else:
		player_2_attack()


func player_1_attack():
	for column_index in range(column_count):
		for row_index in range(rows_count - 1, -1, -1):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != 1:
				# Empty cell or other player's card
				continue
			card.process_attack()


func player_2_attack():
	for column_index in range(column_count):
		for row_index in range(rows_count):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != 2:
				# Empty cell or other player's card
				continue
			card.process_attack()


# Move card from it's current cell to new cell with animation
func move_card(board_cell, card_to_move):
	var prev_board_cell = card_to_move.get_board_cell_or_null()
	assert(prev_board_cell != null)
	var animation = LinMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.2, card_to_move)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	prev_board_cell.remove_card(card_to_move)
	board_cell.add_card(card_to_move)
	fight_global_signals.emit_signal("card_moved", prev_board_cell, board_cell, card_to_move)


# Play card to board cell, with lin animation from stsrt_point to board_cell
func play_card(start_point, board_cell, card_to_play):
	var animation = LinMoveAnimation.new(start_point.global_transform, 
		board_cell.global_transform, 0.2, card_to_play)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	card_to_play.get_parent().remove_child(card_to_play)
	board_cell.add_card(card_to_play)
	fight_global_signals.emit_signal("card_played", board_cell, card_to_play)
	
	
func cancel_highlight():
	for row_index in range(rows_count):
		for column_index in range(column_count):
			var cell = get_board_cell(row_index, column_index)
			cell.cancel_highlight()
