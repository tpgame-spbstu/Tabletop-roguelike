extends Spatial

onready var rows := $rows

var rows_count
var column_count

var _board_width: float

var fight_global_signals
signal board_left_click(board_cell, card)
signal board_right_click(board_cell, card)
signal board_cell_mouse_entered(board_cell)
signal board_cell_mouse_exited(board_cell)


# Set up exturnal nodes, initialize and connect cells
func initialize(fight_global_signals):
	
	self.fight_global_signals = fight_global_signals
	rows_count = rows.get_child_count()
	column_count = rows.get_child(0).get_child_count()
	for row_index in range(rows_count):
		for column_index in range(column_count):
			var cell = get_board_cell(row_index, column_index)
			cell.initialize(self, row_index, column_index)
			cell.connect("input_event", self, "_on_board_cell_input_event")
			cell.connect("mouse_entered_event", self, "_on_board_cell_mouse_entered_event")
			cell.connect("mouse_exited_event", self, "_on_board_cell_mouse_exited_event")
	# get the distance between centers, add the `card_width / 2` from both sides
	_board_width = abs(get_board_cell(0, 0).get_global_transform().origin.x - get_board_cell(0, rows.get_child(0).get_child_count() - 1).get_global_transform().origin.x) + get_board_cell(0, 0).get_size().x


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
	return rows.get_child(row_index).get_child(column_index)


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


func _on_board_cell_mouse_entered_event(board_cell):
	print("entered")
	emit_signal("board_cell_mouse_entered", board_cell)


func _on_board_cell_mouse_exited_event(board_cell):
	print("exited")
	emit_signal("board_cell_mouse_exited", board_cell)


# Give a chance to attack to all player's cards in right order
func process_player_attack(player_number):
	if player_number == 1:
		return player_1_attack()
	else:
		return player_2_attack()


func player_1_attack():
	for column_index in range(column_count):
		for row_index in range(rows_count - 1, -1, -1):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != 1:
				# Empty cell or other player's card
				continue
			var tmp_state = card.process_attack()
			if tmp_state != null:
				yield(tmp_state, "completed")


func player_2_attack():
	for column_index in range(column_count):
		for row_index in range(rows_count):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != 2:
				# Empty cell or other player's card
				continue
			var tmp_state = card.process_attack()
			if tmp_state != null:
				yield(tmp_state, "completed")


# Move card from it's current cell to new cell with animation
func move_card(board_cell, card_to_move):
	var prev_board_cell = card_to_move.get_board_cell_or_null()
	assert(prev_board_cell != null)
	
	# Temporary remove card from cell and add to board root
	prev_board_cell.remove_card(card_to_move)
	self.add_child(card_to_move)
	
	# Play animation
	var animation = SmoothMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.2, card_to_move)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	
	# Add to target cell
	self.remove_child(card_to_move)
	board_cell.add_card(card_to_move)
	
	# Emit global signal
	fight_global_signals.emit_signal("card_moved", prev_board_cell, board_cell, card_to_move)


func cancel_highlight():
	for row_index in range(rows_count):
		for column_index in range(column_count):
			var cell = get_board_cell(row_index, column_index)
			cell.set_highlight_state("none")


func has_free_base_cells(player_number):
	var base_row = get_friendly_base_row_index(player_number)
	for i in range(column_count):
		var cell = get_board_cell(base_row, i)
		if cell != null and typeof(cell) != TYPE_INT and cell.get_card_or_null() == null:
			return true
	return false


func get_cell_neighbours(board_cell):
	var neighbours = []
	if board_cell == null:
		return null
	var row = board_cell.row_index
	var column  = board_cell.column_index
	var cell = get_board_cell(row + 1, column)
	
	if typeof(cell) != TYPE_INT:
		neighbours.append(cell)
	else:
		neighbours.append(null)
	
	cell = get_board_cell(row, column + 1)
	if typeof(cell) != TYPE_INT:
		neighbours.append(cell)
	else:
		neighbours.append(null)
	
	cell = get_board_cell(row - 1, column)
	if typeof(cell) != TYPE_INT:
		neighbours.append(cell)
	else:
		neighbours.append(null)
		
	cell = get_board_cell(row, column - 1)
	if typeof(cell) != TYPE_INT:
		neighbours.append(cell)
	else:
		neighbours.append(null)
	
	return neighbours


func get_board_width() -> float:
	return _board_width
