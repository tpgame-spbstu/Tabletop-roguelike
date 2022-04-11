extends Spatial

var Card = preload("res://Card/card.gd")

signal hand_left_click(hand_cell, card)
signal hand_right_click(hand_cell, card)


func rearange():
	if (get_child_count() == 1):
		var hand_cell = get_child(0) as Spatial
		hand_cell.global_transform = global_transform
	else:
		for i in range(get_child_count()):
			var hand_cell = get_child(i) as Spatial
			hand_cell.global_transform = global_transform.translated(Vector3(3, 0, 0) * (float(i) / (get_child_count() - 1) - 0.5 ))


func add_card(card):
	var hand_cell = load("res://Fight/Human Player/hand_cell.tscn").instance()
	add_child(hand_cell)
	hand_cell.connect("input_event", self, "_on_hand_cell_input_event")
	rearange()
	card.transform = Transform()
	hand_cell.add_child(card)


func remove_card(hand_cell, card):
	assert(is_a_parent_of(hand_cell))
	assert(hand_cell.is_a_parent_of(card))
	hand_cell.remove_child(card)
	remove_child(hand_cell)
	hand_cell.queue_free()
	rearange()


func _on_hand_cell_input_event(hand_cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			var card = null
			for child in hand_cell.get_children():
				if child is Card:
					card = child
					break
			emit_signal("hand_left_click", hand_cell, card)
		elif mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_RIGHT :
			var card = null
			for child in hand_cell.get_children():
				if child is Card:
					card = child
					break
			emit_signal("hand_right_click", hand_cell, card)
		
