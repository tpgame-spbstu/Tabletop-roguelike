extends Spatial

var rows_count
var column_count

signal board_click(board_cell, card)


func initialize(fight_location):
	rows_count = get_child_count()
	column_count = get_child(0).get_child_count()
	for row_index in range(rows_count):
		for column_index in range(column_count):
			var cell = get_board_cell(row_index, column_index)
			cell.initialize(self, row_index, column_index)
			cell.connect("input_event", self, "_on_board_cell_input_event")

func get_board_cell(row_index, column_index):
	if row_index < 0:
		return "up"
	if row_index >= rows_count:
		return "down"
	if column_index < 0 or column_index >= column_count:
		return null
	return get_child(row_index).get_child(column_index)


func _on_board_cell_input_event(board_cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			emit_signal("board_click", board_cell, board_cell.get_card_or_null())


func _on_player_attack_enter(fight_state):
	for column_index in range(column_count):
		for row_index in range(rows_count - 1, -1, -1):
			var cell = get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or !card.is_owned_by_player_1:
				continue
			card.process_attack(fight_state)
