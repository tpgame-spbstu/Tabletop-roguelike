extends Spatial


signal cell_click(cell, card)

func initialize(fight_location):
	connect("cell_click", fight_location, "_on_board_click")

func _ready():
	var rows = get_children()
	for row_index in range(rows.size()):
		var cells = rows[row_index].get_children()
		for cell_index in range(cells.size()):
			cells[cell_index].connect_to_board(self, row_index, cell_index)

func _on_cell_click(cell : Spatial):
	emit_signal("cell_click", cell, cell.get_node_or_null("card"))
