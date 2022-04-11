extends Reference

var card_name : String
var play_cost : Cost
var common_symbols : Dictionary
var mod_symbols : Dictionary
var health : int
var power : int

func _init(card_name, play_cost, common_symbol_names, mod_symbol_names, power, health):
	self.card_name = card_name
	self.play_cost = play_cost	
	for symbol_name in common_symbol_names:
		common_symbols[symbol_name] = SymbolManager.get_symbol_copy(symbol_name)
	for symbol_name in mod_symbol_names:
		mod_symbols[symbol_name] = SymbolManager.get_symbol_copy(symbol_name)
	self.power = power
	self.health = health

