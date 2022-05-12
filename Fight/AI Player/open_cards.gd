extends Spatial


var _cards = []
var margin_left = 0.4
var margin_right = 0.4
var _last_hovered_index = 0
var _is_hovered = false


signal hovered_card_changed(card)
signal card_left_click(card)
signal card_right_click(card)


func get_cards_count():
	return _cards.size()


func is_hovered():
	return _is_hovered


func add_card(card, position = 'front'):
	assert(position == 'front' or position == 'back')
	if position == 'front':
		_cards.push_front(card)
	else:
		_cards.push_back(card)
	add_child(card)
	card.transform = Transform()
	reset_cards_positions()


func remove_empty():
	var i = 0
	while i < _cards.size():
		if _cards[i] == null:
			_cards.remove(i)
		else:
			i += 1
	_is_hovered = false
	_set_hovered_index(0)


func remove_card(card):
	assert(card != null)
	assert(card in _cards)
	var card_transform = card.global_transform
	remove_child(card)
	var index = _cards.find(card)
	_cards[index] = null
	return card_transform


func reset_cards_positions():
	for i in _last_hovered_index:
		if _cards[i]:
			_cards[i].transform.origin = Vector3(_get_pos_from_index(i), 0, 0)
			_cards[i].rotation.z = 0.1
	var card = get_last_hovered_card()
	if card:
		card.rotation.z = 0
		if is_hovered():
			card.transform.origin = Vector3(
				_get_pos_from_index(_last_hovered_index), 0.1, 0.1)
		else:
			card.transform.origin = Vector3(
				_get_pos_from_index(_last_hovered_index), 0.05, 0)
	for i in range(_last_hovered_index + 1, _cards.size()):
		if _cards[i]:
			_cards[i].transform.origin = Vector3(_get_pos_from_index(i), 0, 0)
			_cards[i].rotation.z = -0.1


func _get_pos_from_index(index):
	if _cards.size() <= 1:
		return 0.0
	var scale_bound = $lin_hover_scale.scale.x / 2
	return ((scale_bound - margin_left)
		- (2 * scale_bound - margin_left - margin_right) 
		/ (_cards.size() - 1) * index)


func _get_index_from_value(value):
	var scale_bound = $lin_hover_scale.scale.x / 2
	var left_margin_fraction = margin_left / $lin_hover_scale.scale.x 
	var right_margin_fraction = 1 - margin_right / $lin_hover_scale.scale.x
	value = value / right_margin_fraction
	left_margin_fraction = left_margin_fraction / right_margin_fraction
	value = (value - left_margin_fraction) / (1 - left_margin_fraction)
	var index = floor((value * (_cards.size() - 1) * 2 + 1) / 2)
	if index < 0:
		index = 0
	if index >= _cards.size():
		index = _cards.size() - 1
	return index


func get_last_hovered_card():
	if _last_hovered_index in range(_cards.size()):
		return _cards[_last_hovered_index]
	else:
		return null


func _set_hovered_index(index):
	_last_hovered_index = index
	reset_cards_positions()
	emit_signal("hovered_card_changed", get_last_hovered_card())


func _process_new_hover_value(value):
	var index = _get_index_from_value(value)
	if !is_hovered():
		_is_hovered = true
		_set_hovered_index(index)
	else:
		if index != _last_hovered_index:
			_set_hovered_index(index)


func _on_lin_hover_scale_mouse_motion(value):
	_process_new_hover_value(value)


func _on_lin_hover_scale_mouse_exited():
	_is_hovered = false
	reset_cards_positions()
	emit_signal("hovered_card_changed", null)


func _on_lin_hover_scale_left_click(value):
	_process_new_hover_value(value)
	emit_signal("card_left_click", get_last_hovered_card())


func _on_lin_hover_scale_right_click(value):
	_process_new_hover_value(value)
	emit_signal("card_right_click", get_last_hovered_card())
