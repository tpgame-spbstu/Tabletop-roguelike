extends Spatial

var rows_count
var column_count
var fight_global_signals

signal board_left_click(board_cell, card)
signal board_right_click(board_cell, card)


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
	if row_index < 0:
		return 2
	if row_index >= rows_count:
		return 1
	if column_index < 0 or column_index >= column_count:
		return null
	return get_child(row_index).get_child(column_index)


func get_friendly_base_row_index(player_number):
	if player_number == 1:
		return 0
	else:
		return 3


func get_enemy_base_row_index(player_number):
	if player_number == 1:
		return 3
	else:
		return 0


func _on_board_cell_input_event(board_cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			emit_signal("board_left_click", board_cell, board_cell.get_card_or_null())
		elif mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_RIGHT :
			emit_signal("board_right_click", board_cell, board_cell.get_card_or_null())


func _on_attack_enter(fight_state, player_number):
	if player_number == 1:
		_on_player_1_attack_enter(fight_state)
	else:
		_on_player_2_attack_enter(fight_state)


func _on_player_1_attack_enter(fight_state):
	for column_index in range(column_count):
		for row_index in range(rows_count - 1, -1, -1):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number == 2:
				continue
			card.process_attack(fight_state)


func _on_player_2_attack_enter(fight_state):
	for column_index in range(column_count):
		for row_index in range(rows_count):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number == 1:
				continue
			card.process_attack(fight_state)


func move_card(board_cell, card_to_move):
	var prev_board_cell = card_to_move.get_board_cell_or_null()
	assert(prev_board_cell != null)
	card_to_move.animation = LinMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.1, card_to_move)
	yield(card_to_move, "animation_ended")
	prev_board_cell.remove_card(card_to_move)
	board_cell.add_card(card_to_move)
	fight_global_signals.emit_signal("card_moved", prev_board_cell, board_cell, card_to_move)


func play_card(start_point, board_cell, card_to_play):
	card_to_play.animation = LinMoveAnimation.new(start_point.global_transform, 
		board_cell.global_transform, 0.1, card_to_play)
	yield(card_to_play, "animation_ended")
	card_to_play.get_parent().remove_child(card_to_play)
	board_cell.add_card(card_to_play)
	fight_global_signals.emit_signal("card_played", board_cell, card_to_play)
