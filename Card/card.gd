extends Spatial

enum {DECK, HAND, BOARD}

var BoardCell := load("res://Fight/board_cell.gd") as Script
var HandCell := load("res://Fight/hand_cell.gd") as Script
var CardConfig := load("res://Card/card_config.gd")
export var owner_number : int
var src_config
var card_name : String
var play_cost : Cost
onready var symbols = $symbols
export var health : int
var power : int
var animation = null
const player_attack_direction = {1: 1, 2: -1}

onready var card_visuals_2d = $card_visuals/Viewport/card_visuals_2d


signal animation_ended()


func initialize(card_config, owner_number):
	self.owner_number = owner_number
	src_config = card_config
	card_name = card_config.card_name
	play_cost = card_config.play_cost
	for symbol_scn in card_config.symbols:
		var symbol = symbol_scn.instance()
		symbols.add_child(symbol)
		symbol.initialize(self)
	health = card_config.health
	power = card_config.power
	card_visuals_2d.update_to_card(self)


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
	var target_board_cell = board_cell.get_relative_board_cell(player_attack_direction[owner_number], 0)
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
	if board_cell.is_friendly_base(owner_number) && delta_row_abs == 1:
		return Cost.new(1, 0, 0)
	else:
		return Cost.new(2, 0, 0)
