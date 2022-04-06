extends Spatial

var Card := load("res://Card/card.gd") as Script

var row_index = NAN
var column_index = NAN

var board


signal input_event(board_cell, event)


func get_card_or_null():
	for child in get_children():
		if Card.instance_has(child):
			return child
	return null

func is_player_1_base():
	return row_index == 0

func is_friendly_base(owner_number):
	if owner_number == 1:
		return is_player_1_base()
	else:
		return is_player_2_base()

func is_enemy_base(owner_number):
	if owner_number == 1:
		return is_player_2_base()
	else:
		return is_player_1_base()


func is_player_2_base():
	return row_index == board.rows_count - 1


func get_relative_board_cell(delta_row, delta_column):
	return board.get_board_cell(row_index + delta_row, column_index + delta_column)


func initialize(board, row_index , column_index):
	self.board = board
	self.row_index = row_index
	self.column_index = column_index


func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	emit_signal("input_event", self, event)


func add_card(card):
	add_child(card)
	card.transform = Transform()

func remove_card(card):
	remove_child(card)
	card.transform = Transform()
