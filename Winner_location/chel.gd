extends Spatial

onready var area = $Model/Root/Area
signal input_ant


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			emit_signal("input_ant")
