extends "res://Symbols/symbol.gd"

# WeakeningEffect symbol - effect, than lowers card's attack power by 1

var BoardCell := preload("res://Fight/board_cell.gd") as Script

var source = null


func _on_card_is_dead(_board_cell, _card):
	analyze_board()


func _on_card_moved(_prev_board_cell, _cur_board_cell, _card):
	analyze_board()


# Check if source is stil valid
func analyze_board():
	if card == null:
		return
	var board_cell = card.get_board_cell_or_null()
	if board_cell == null:
		# Card not on board
		disconnect_and_remove()
		return
	var source_cell = board_cell.get_relative_board_cell(card.player_attack_direction[card.owner_number], 0)
	if source_cell == null or typeof(source_cell) == TYPE_INT:
		# Source cell does not exist
		disconnect_and_remove()
		return
	var source_card = source_cell.get_card_or_null()
	if source_card == null or !source_card.has_symbol("weakening"):
		# Source cell is empty or source card doesn't have "weakening" symbol
		disconnect_and_remove()
		return
	var symbol = source_card.get_symbol_or_null("weakening")
	if symbol != source:
		# Symbol is not a source
		disconnect_and_remove()
		return


func disconnect_and_remove():
	card.card_config.power += 1
	var connections = self.get_incoming_connections()
	for cur_conn in connections:
		cur_conn.source.disconnect(cur_conn.signal_name, self, cur_conn.method_name)
	source = null
	card.remove_effect_symbol(self)


func _init(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred).(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred):
	pass


func initialize(card):
	.initialize(card)
	card.card_config.power -= 1
	card.fight_global_signals.connect("card_moved", self, "_on_card_moved")
	card.fight_global_signals.connect("card_is_dead", self, "_on_card_is_dead")
