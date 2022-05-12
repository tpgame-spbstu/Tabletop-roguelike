extends Area

signal mouse_motion(value)
signal left_click(value)
signal right_click(value)


func value_from_local(local_position):
	return -local_position.x + 0.5


func _on_self_input_event(camera, event, position, normal, shape_idx):
	var local_position := to_local(position)
	var value = value_from_local(local_position)
	if abs(value) > 1:
		return
	if event is InputEventMouseMotion:
		emit_signal("mouse_motion", value)
	elif event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			# Left click on board cell
			emit_signal("left_click", value)
		elif mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_RIGHT :
			# Right click on board cell
			emit_signal("right_click", value)
