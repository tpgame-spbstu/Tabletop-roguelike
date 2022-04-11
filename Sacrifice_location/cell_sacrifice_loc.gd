extends Spatial

signal input_event(cell, event)

func _on_cell_input_event(camera, event, position, normal, shape_idx):
	emit_signal("input_event", self, event)
