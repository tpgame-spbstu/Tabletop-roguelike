extends "res://Symbols/symbol.gd"


func analyze_board():
	if card == null:
		return
	var board_cell = card.get_board_cell_or_null()
	if board_cell == null:
		return
	var effected_cell = board_cell.get_relative_board_cell(card.player_attack_direction[card.owner_number], 0)
	if effected_cell == null or typeof(effected_cell) == TYPE_INT:
		return
	var effected_card = effected_cell.get_card_or_null()
	if effected_card == null:
		return
	var symbol = effected_card.get_symbol_or_null("weakening effect")
	if symbol != null && symbol.source == self:
		return
	var effect = SymbolManager.get_symbol_copy("weakening effect")
	effect.source = self
	effected_card.add_symbol(effect)


func _on_card_played(_board_cell, _card):
	analyze_board()


func _on_card_is_dead(_board_cell, _card):
	analyze_board()


func _on_card_moved(prev_board_cell, cur_board_cell, _card):
	analyze_board()


func _init(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred).(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred):
	pass


func initialize(card):
	.initialize(card)
	card.fight_global_signals.connect("card_moved", self, "_on_card_moved")
	card.fight_global_signals.connect("card_is_dead", self, "_on_card_is_dead")
	card.fight_global_signals.connect("card_played", self, "_on_card_played")
