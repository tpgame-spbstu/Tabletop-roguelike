extends Spatial

# Card class - card class for fight

signal anim_finished
signal contact
signal finished_anim

var BoardCell := load("res://Fight/board_cell.gd") as Script
var CardConfig := load("res://Card/card_config.gd")
var _dmg_sticker = load("res://Fight/damage_anim/dmg_sticker.tscn")

var owner_number
# Personal copy of src_config
var card_config
# Original card config
var src_config
# counts the number of active animations
var _anim_cnt = 0

const player_attack_direction = {1: 1, 2: -1}

var fight_global_signals
var fight_state

onready var card_visuals = $card_visuals
onready var unit_visuals = $unit_visuals


func get_size():
	return Vector3(0.8, 0.02, 1)


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


func attack(victim):
	_register($AnimationPlayer, "animation_finished")
	# long-ranged \ not; forward \ backward attack
	$AnimationPlayer.play("%sattack_%s" % ["range_" if has_symbol("range") else "", owner_number])
	# wait for the moment of contact in the attack animation
	yield(self, "contact")

	# base
	if typeof(victim) == TYPE_INT:
		fight_state.reduce_enemy_health(owner_number, card_config.power)
	else:  # enemy's card
		# _register(victim, "anim_finished")  # <- seems redundant, but not thoroughly tested
		yield(victim._get_hit(self), "completed")


func get_victim():
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)

	if not _can_attack():
		# can't attack if power 0 or less or dead
		return

	# Get target cell to attack
	var attack_range = 1
	if has_symbol("range"):
		attack_range += 1

	var target_board_cell = board_cell.get_relative_board_cell(attack_range * player_attack_direction[owner_number], 0)
	# empty space behind the enemy's base
	if target_board_cell and typeof(target_board_cell) == TYPE_INT and target_board_cell != owner_number:
		print("other branch")
		return owner_number
	var target_card = target_board_cell.get_card_or_null()
	# aha, empty board cell
	if not target_card:
		# is that cell belongs to the enemy?
		if target_board_cell.is_enemy_base(owner_number):
			return owner_number
	# attack the enemy's card
	elif not _is_ally(target_card):
		return target_card


## changes the internals and externals of the card
## play the relevant animations
##
## :attacker: the card, that dared to attack this card
func _get_hit(attacker):
	card_config.health -= attacker.card_config.power
	card_visuals.update()
	unit_visuals.update()

	# prepare the various animations: instantiate and register
	_register($AnimationPlayer, "animation_finished")
	var dmg_sticker = _dmg_sticker.instance()
	add_child(dmg_sticker)
	_register(dmg_sticker, "tween_finished")

	var dir = Vector3(0, 1, 1).rotated(Vector3.RIGHT, get_viewport().get_camera().get_camera_transform().basis.get_euler().x + PI / 2)
	
	# set the animations in motion
	dmg_sticker.create(attacker.card_config.power, dir, 0, false, 1)
	$AnimationPlayer.play("being_beaten")

	# wait for the animations to completely finish (all of them)
	yield(self, "anim_finished")
	if card_config.health <= 0:
		_die()
	else:
		dmg_sticker.queue_free()

		if has_symbol("counterattack"):
			# start the attacking routine
			var victim = get_victim()
			# check if there any card to attack and whether it
			# matches the one that attacked this card
			if victim and victim == attacker:
				yield(attack(victim), "completed")


func _on_card_played(board_cell, card):
	if card == self:
		# if this card is played, change visuals mode
		card_visuals.hide()
		unit_visuals.show()


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


func _die():
	var board_cell = get_board_cell_or_null()
	assert(board_cell != null)
	board_cell.remove_card(self)
	fight_global_signals.emit_signal("card_is_dead", get_board_cell_or_null(), self)
	queue_free()


func _can_attack():
	return card_config.power > 0 and card_config.health > 0


func _is_ally(suspect):
	return owner_number == suspect.owner_number


func _register(obj, signal_to_wait):
	_anim_cnt += 1
	obj.connect(signal_to_wait, self, "_unregister", [], CONNECT_ONESHOT)


func _unregister(_a=[]):
	_anim_cnt -= 1
	if not _anim_cnt:
		emit_signal("anim_finished")
