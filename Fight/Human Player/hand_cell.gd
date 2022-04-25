extends Spatial

var Card := load("res://Card/card.gd") as Script
signal input_event(hand_cell, event)

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	emit_signal("input_event", self, event)
