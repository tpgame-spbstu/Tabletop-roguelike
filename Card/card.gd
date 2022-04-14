extends Spatial

enum {DECK, HAND, BOARD}

var BoardCell := load("res://Fight/board_cell.gd") as Script
var HandCell := load("res://Fight/Human Player/hand_cell.gd") as Script
var CardConfig := load("res://Card/card_config.gd")

var owner_number
var src_config
var card_config

const player_attack_direction = {1: 1, 2: -1}

var fight_global_signals

onready var card_visuals = $card_visuals
onready var unit_visuals = $unit_visuals


func initialize(card_config, owner_number, fight_global_signals):
	self.fight_global_signals = fight_global_signals
	self.owner_number = owner_number
	self.src_config = card_config
	self.card_config = card_config.get_copy()
	self.card_config.initialize_symbols(self)
	card_visuals.initialize(self.card_config, owner_number)
	unit_visuals.initialize(self.card_config, owner_number)
	fight_global_signals.connect("card_played", self, "_on_card_played")


func get_board_cell_or_null():
	var parent = get_parent()
	return parent if BoardCell.instance_has(parent) else null


func get_hand_cell_or_null():
	var parent = get_parent()
	return parent if HandCell.instance_has(parent) else null


func reduce_health(delta, fight_state):
	card_config.health -= delta
	card_visuals.update()
	if card_config.health <= 0:
		die()
		return
	if has_symbol("counterattack"):
		process_attack(fight_state)


func _on_card_played(board_cell, card):
	if card == self:
		card_visuals.hide()
		unit_visuals.show()


func die():
	get_parent().remove_child(self)
	fight_global_signals.emit_signal("card_is_dead", get_board_cell_or_null(), self)
	queue_free()


func process_attack(fight_state):
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	if card_config.power <= 0:
		return
	var attack_range = 1
	if has_symbol("range"):
		attack_range += 1
	var target_board_cell = board_cell.get_relative_board_cell(attack_range * player_attack_direction[owner_number], 0)
	if target_board_cell == null:
		return
	if typeof(target_board_cell) == TYPE_INT:
		if target_board_cell != owner_number:
			fight_state.reduse_enemy_health(owner_number, card_config.power)
		return
	var target_card = target_board_cell.get_card_or_null()
	if target_card == null:
		if target_board_cell.is_enemy_base(owner_number):
			fight_state.reduse_enemy_health(owner_number, card_config.power)
		return
	if target_card.owner_number == owner_number:
		return
	target_card.reduce_health(card_config.power, fight_state)
		


func get_move_cost_or_null(target_board_cell):
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	if target_board_cell == board_cell:
		return null
	if target_board_cell.get_card_or_null() != null:
		return null
	var delta_row_abs = target_board_cell.row_index - board_cell.row_index
	delta_row_abs *= 1 if delta_row_abs > 0 else -1
	var delta_column_abs = target_board_cell.column_index - board_cell.column_index
	delta_column_abs *= 1 if delta_column_abs > 0 else -1
	if target_board_cell.is_enemy_base(owner_number) or (delta_row_abs + delta_column_abs != 1):
		return null
	var delta = 0
	if has_symbol("fast"):
		delta -= 1
	if has_symbol("slow"):
		delta += 1
	if board_cell.is_friendly_base(owner_number) && delta_row_abs == 1:
		return Cost.new(1 + delta, 0, 0)
	else:
		return Cost.new(2 + delta, 0, 0)


func get_symbol_or_null(symbol_name):
	for symbol in card_config.common_symbols:
		if symbol.symbol_name == symbol_name:
			return symbol
	for symbol in card_config.mod_symbols:
		if symbol.symbol_name == symbol_name:
			return symbol
	for symbol in card_config.effect_symbols:
		if symbol.symbol_name == symbol_name:
			return symbol
	return null


func has_symbol(symbol_name):
	for symbol in card_config.common_symbols:
		if symbol.symbol_name == symbol_name:
			return true
	for symbol in card_config.mod_symbols:
		if symbol.symbol_name == symbol_name:
			return true
	for symbol in card_config.effect_symbols:
		if symbol.symbol_name == symbol_name:
			return true
	return false


func add_effect_symbol(symbol):
	card_config.effect_symbols.append(symbol)
	symbol.initialize(self)
	card_visuals.update()
	unit_visuals.update()


func remove_effect_symbol(symbol):
	card_config.effect_symbols.erase(symbol)
	card_visuals.update()
	unit_visuals.update()
