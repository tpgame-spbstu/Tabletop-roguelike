extends Reference

# CardConfig class - class for storing card configuration

var card_name : String
var play_cost : Cost
var common_symbols : Array
var mod_symbols : Array
var effect_symbols : Array
var health : int
var power : int


func _init(card_name, play_cost, common_symbols, mod_symbols, effect_symbols, power, health):
	self.card_name = card_name
	self.play_cost = play_cost
	
	for symbol in common_symbols:
		self.common_symbols.append(symbol.get_copy())
	for symbol in mod_symbols:
		self.mod_symbols.append(symbol.get_copy())
	for symbol in effect_symbols:
		self.effect_symbols.append(symbol.get_copy())
	self.power = power
	self.health = health


func get_copy():
	return get_script().new(card_name, play_cost, common_symbols, mod_symbols, effect_symbols, power, health)


func initialize_symbols(card):
	for symbol_list in [common_symbols, mod_symbols, effect_symbols]:
		for symbol in symbol_list:
			symbol.initialize(card)
