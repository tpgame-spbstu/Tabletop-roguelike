extends Spatial

enum {DECK, HAND, BOARD}

var BoardCell := load("res://Fight/board_cell.gd") as Script
var HandCell := load("res://Fight/hand_cell.gd") as Script
var CardConfig := load("res://Card/card_config.gd")
export var owner_number : int
var common_symbols : Dictionary
var mod_symbols : Dictionary
var src_config
var card_name : String
var play_cost : Cost
export var health : int
var power : int
var animation = null
const player_attack_direction = {1: 1, 2: -1}

onready var card_visuals_2d = $card_visuals/Viewport/card_visuals_2d
onready var unit_visuals_2d = $unit_visuals2/Viewport/unit_visuals_2d

signal animation_ended()


func initialize(card_config, owner_number):
	self.owner_number = owner_number
	src_config = card_config
	card_name = card_config.card_name
	play_cost = card_config.play_cost
	for symbol_name in card_config.common_symbols:
		var symbol = SymbolManager.get_symbol_copy(symbol_name)
		common_symbols[symbol_name] = symbol
		symbol.initialize(self)
	for symbol_name in card_config.mod_symbols:
		var symbol = SymbolManager.get_symbol_copy(symbol_name)
		mod_symbols[symbol_name] = symbol
		symbol.initialize(self)
	health = card_config.health
	power = card_config.power
	card_visuals_2d.update_to_card(self)
	unit_visuals_2d.update_to_card(self)


func _process(delta):
	if animation != null:
		if animation.process(delta):
			animation = null
			emit_signal("animation_ended")


func get_board_cell_or_null():
	var parent = get_parent()
	return parent if BoardCell.instance_has(parent) else null


func get_hand_cell_or_null():
	var parent = get_parent()
	return parent if HandCell.instance_has(parent) else null


func reduce_health(delta):
	health -= delta
	card_visuals_2d.update_to_card(self)
	if health <= 0:
		get_parent().remove_child(self)
		queue_free()


func process_attack(fight_state):
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	var attack_range = 1
	if has_symbol("range"):
		attack_range += 1
	var target_board_cell = board_cell.get_relative_board_cell(attack_range * player_attack_direction[owner_number], 0)
	if target_board_cell == null:
		return
	if BoardCell.instance_has(target_board_cell):
		var target_card = target_board_cell.get_card_or_null()
		if target_card == null:
			if target_board_cell.is_enemy_base(owner_number):
				fight_state.reduse_enemy_health(owner_number, power)
			return
		if target_card.owner_number == owner_number:
			return
		target_card.reduce_health(power)
	else:
		if target_board_cell != owner_number:
			fight_state.reduse_enemy_health(owner_number, power)
		


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
	var symbol = common_symbols[symbol_name]
	if symbol == null:
		symbol = mod_symbols[symbol_name]
	return symbol

func has_symbol(symbol_name):
	return common_symbols.has(symbol_name) || mod_symbols.has(symbol_name)
