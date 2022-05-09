extends Spatial

# Card class - card class for fight

var BoardCell := load("res://Fight/board_cell.gd") as Script
var CardConfig := load("res://Card/card_config.gd")

var owner_number
# Personal copy of src_config
var card_config
# Original card config
var src_config

const player_attack_direction = {1: 1, 2: -1}

var fight_global_signals
var fight_state

onready var card_visuals = $card_visuals
onready var unit_visuals = $unit_visuals


func initialize(card_config, owner_number, fight_global_signals, fight_state):
	self.fight_global_signals = fight_global_signals
	self.fight_state = fight_state
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


# Process incoming damage
func reduce_health(delta):
	card_config.health -= delta
	card_visuals.update()
	unit_visuals.update()
	$AnimationPlayer.play("being_beaten")
	yield($AnimationPlayer, "animation_finished")
	if card_config.health <= 0:
		die()
		return
	if has_symbol("counterattack"):
		var tmp_state = process_attack()
		if tmp_state != null:
			yield(tmp_state, "completed")


func _on_card_played(board_cell, card):
	if card == self:
		# if this card is played, change visuals mode
		card_visuals.hide()
		unit_visuals.show()


func die():
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	board_cell.remove_card(self)
	fight_global_signals.emit_signal("card_is_dead", get_board_cell_or_null(), self)
	queue_free()


func process_attack():
	var board_cell = get_board_cell_or_null()
	var anim_name = "attack_" + str(owner_number)
	print(anim_name)
	assert(board_cell != null)
	if card_config.power <= 0 or card_config.health <= 0:
		# can't attack if power 0 or less or dead
		return
	# Get target cell to attack
	var attack_range = 1
	if has_symbol("range"):
		anim_name = "range_attack_" + str(owner_number)
		attack_range += 1
	var target_board_cell = board_cell.get_relative_board_cell(attack_range * player_attack_direction[owner_number], 0)
	if target_board_cell == null:
		# can't attack if target cell completely out of bounds
		return
	if typeof(target_board_cell) == TYPE_INT:
		# If target cell is out of bounds, but base
		if target_board_cell != owner_number:
			$AnimationPlayer.play(anim_name)
			yield($AnimationPlayer, "animation_finished")
			# Attack enemy base
			fight_state.reduce_enemy_health(owner_number, card_config.power)
		return
	var target_card = target_board_cell.get_card_or_null()
	if target_card == null:
		if target_board_cell.is_enemy_base(owner_number):
			$AnimationPlayer.play(anim_name)
			yield($AnimationPlayer, "animation_finished")
			# Attack if target cell is enemy base and empty
			fight_state.reduce_enemy_health(owner_number, card_config.power)
		return
	if target_card.owner_number == owner_number:
		# can't attack friendly card
		return
	$AnimationPlayer.play(anim_name)
	yield($AnimationPlayer, "animation_finished")
	# Attack enemy card
	yield(target_card.reduce_health(card_config.power), "completed")


func get_move_cost_or_null(target_board_cell):
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	if target_board_cell == board_cell:
		# target cell is a current cell
		return null
	if target_board_cell.get_card_or_null() != null:
		# target cell is not enpty
		return null
	var delta_row_abs = target_board_cell.row_index - board_cell.row_index
	delta_row_abs *= 1 if delta_row_abs > 0 else -1
	var delta_column_abs = target_board_cell.column_index - board_cell.column_index
	delta_column_abs *= 1 if delta_column_abs > 0 else -1
	if delta_row_abs + delta_column_abs != 1:
		# not a neighbour cell
		return null
	if target_board_cell.is_enemy_base(owner_number):
		# can't move to enemy base
		return null
	var delta = 0
	if has_symbol("fast"):
		delta -= 1
	if has_symbol("slow"):
		delta += 1
		
	if board_cell.is_friendly_base(owner_number) && delta_row_abs == 1:
		# Discount for exiting base
		return Cost.new(1 + delta, 0, 0)
	else:
		return Cost.new(2 + delta, 0, 0)


func get_symbol_or_null(symbol_name):
	for symbol_list in [card_config.common_symbols, card_config.mod_symbols, card_config.effect_symbols]:
		for symbol in symbol_list:
			if symbol.symbol_name == symbol_name:
				return symbol
	return null


func has_symbol(symbol_name):
	for symbol_list in [card_config.common_symbols, card_config.mod_symbols, card_config.effect_symbols]:
		for symbol in symbol_list:
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


func get_size():
	var platform = card_visuals.platform as MeshInstance
	var aabb = platform.get_aabb()
	return aabb.size.move_toward(Vector3(0,1,0),0.001)


func get_card_visuals():
	return card_visuals


func get_unit_visuals():
	return unit_visuals
