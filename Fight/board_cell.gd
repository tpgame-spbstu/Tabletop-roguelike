extends Spatial

var Card := load("res://Card/card.gd") as Script

var highlight_state_dict = {
	"none": preload("res://Fight/Assets/base_board_cell_material.tres"),
	"playable": preload("res://Fight/Assets/selected_board_cell_material.tres"),
	"targeted": preload("res://Fight/Assets/targeted_board_cell_material.tres")
	}

var row_index = NAN
var column_index = NAN
var is_highlighted = false
var board
var highlight_state = "none"


signal input_event(board_cell, event)
signal mouse_entered_event(board_cell)
signal mouse_exited_event(board_cell)


# Set up exturnal nodes references and coordinates
func initialize(board, row_index , column_index):
	self.board = board
	self.row_index = row_index
	self.column_index = column_index


# Get attached card if there is one
func get_card_or_null():
	for child in get_children():
		if Card.instance_has(child):
			return child
	return null


# Is this sell a part of player 1 base row
func is_player_1_base():
	return row_index == 0


# Is this sell a part of player 2 base row
func is_player_2_base():
	return row_index == board.rows_count - 1


# Is this sell a part of this player's base row
func is_friendly_base(owner_number):
	if owner_number == 1:
		return is_player_1_base()
	else:
		return is_player_2_base()


# Is this sell a part of other player's base row
func is_enemy_base(owner_number):
	if owner_number == 1:
		return is_player_2_base()
	else:
		return is_player_1_base()


# Get a cell that is shifted in coordinates relative to this cell
func get_relative_board_cell(delta_row, delta_column):
	return board.get_board_cell(row_index + delta_row, column_index + delta_column)


# Input event handler
func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	# Reemit signal
	emit_signal("input_event", self, event)


# Attach card to this cell
func add_card(card):
	add_child(card)
	card.transform = Transform()


# Remove card from this cell
func remove_card(card):
	remove_child(card)
	card.transform = Transform()


func set_highlight_state(state):
	if state != highlight_state:
		$MeshInstance.set_surface_material(0, highlight_state_dict[state])
		highlight_state = state


func get_size() -> Vector2:
	var m_inst = get_node("MeshInstance") as MeshInstance
	var mesh = m_inst.get_mesh() as QuadMesh
	var scale = m_inst.get_scale()
	return mesh.get_size() * Vector2(scale.x, scale.y)


func _on_Area_mouse_entered():
	emit_signal("mouse_entered_event", self)


func _on_Area_mouse_exited():
	emit_signal("mouse_exited_event", self)
