extends Spatial


signal card_changed(val)

export(Array) var cards = []
export(float) var margin_left = 0.4
export(float) var margin_right = 0.4


func get_open_cards_count():
	return cards.size()


func get_pos_from_index(index):
	var scale_bound = $lin_hover_scale.scale.x / 2
	return ((scale_bound - margin_left)
		- (2 * scale_bound - margin_left - margin_right) 
		/ (get_open_cards_count() - 1) * index)


func reset_cards_positions():
	for i in cards.size():
		var card := get_node(cards[i]) as Spatial
		card.transform.origin = Vector3(get_pos_from_index(i), 0, 0)
		card.rotation.z = 0.1


func _ready():
	reset_cards_positions()

func get_index_from_value(value):
	var scale_bound = $lin_hover_scale.scale.x / 2
	var left_margin_fraction = margin_left / $lin_hover_scale.scale.x 
	var right_margin_fraction = 1 - margin_right / $lin_hover_scale.scale.x
	value = value / right_margin_fraction
	left_margin_fraction = left_margin_fraction / right_margin_fraction
	value = (value - left_margin_fraction) / (1 - left_margin_fraction)
	var index = floor((value * (get_open_cards_count() - 1) * 2 + 1) / 2)
	if index < 0:
		index = 0
	if index >= get_open_cards_count():
		index = get_open_cards_count() - 1
	return index


func _on_lin_hover_scale_mouse_motion(value):
	reset_cards_positions()
	var index = get_index_from_value(value)
	var card := get_node(cards[index]) as Spatial
	card.rotation.z = 0
	card.transform.origin.y = 0.1
	emit_signal("card_changed", value)


func _on_lin_hover_scale_mouse_exited():
	reset_cards_positions()
