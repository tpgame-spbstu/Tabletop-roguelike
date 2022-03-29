extends Spatial

var row_index = NAN
var cell_index = NAN

signal cell_click(cell)

func get_card():
	return get_node_or_null("card")

func connect_to_board(board, row_index , cell_index):
	self.row_index = row_index
	self.cell_index = cell_index
	self.connect("cell_click", board, "_on_cell_click")

func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			emit_signal("cell_click", self)
