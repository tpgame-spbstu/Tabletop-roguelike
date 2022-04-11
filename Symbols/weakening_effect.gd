extends "res://Symbols/symbol.gd"


var BoardCell := preload("res://Fight/board_cell.gd") as Script

var source = null


func _on_card_is_dead(_board_cell, _card):
	analyze_board()


func _on_card_moved(_prev_board_cell, _cur_board_cell, _card):
	analyze_board()


func analyze_board():
	if card == null:
		return
	var board_cell = card.get_board_cell_or_null()
	if board_cell == null:
		disconnect_and_remove()
		return
	var source_cell = board_cell.get_relative_board_cell(card.player_attack_direction[card.owner_number], 0)
	if source_cell == null or typeof(source_cell) == TYPE_INT:
		disconnect_and_remove()
		return
	var source_card = source_cell.get_card_or_null()
	if source_card == null or !source_card.has_symbol("weakening"):
		disconnect_and_remove()
		return
	var symbol = source_card.get_symbol_or_null("weakening")
	if symbol != source:
		disconnect_and_remove()
		return


func disconnect_and_remove():
	var connections = self.get_incoming_connections()
	for cur_conn in connections:
		cur_conn.source.disconnect(cur_conn.signal_name, self, cur_conn.method_name)
	source = null
	card.remove_symbol(symbol_name)


func _init(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred).(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred):
	pass


func initialize(card):
	.initialize(card)
	card.fight_global_signals.connect("card_moved", self, "_on_card_moved")
	card.fight_global_signals.connect("card_is_dead", self, "_on_card_is_dead")