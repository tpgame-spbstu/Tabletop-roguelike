extends Node

var symbol_dictionary : Dictionary


func list_symbol(symbol):
	assert(!symbol_dictionary.has(symbol.symbol_name))
	symbol_dictionary[symbol.symbol_name] = symbol


func get_symbol(symbol_name):
	assert(symbol_dictionary.has(symbol_name))
	return symbol_dictionary[symbol_name]


func get_symbol_copy(symbol_name):
	assert(symbol_dictionary.has(symbol_name))
	return symbol_dictionary[symbol_name].get_copy()
	
func _ready():
	var fast_symbol = Symbol.new("fast", "res://Symbols/Textures/sym_fast.tres", "Передвижение дешевле на 1 энергию.", true, true)
	var slow_symbol = Symbol.new("slow", "res://Symbols/Textures/sym_fast.tres", "Передвижение дороже на 1 энергию.", true, true)
	var range_symbol = Symbol.new("range", "res://Symbols/Textures/sym_fast.tres", "Атака на одну клетку дальше.", true, true)
	list_symbol(fast_symbol)
	list_symbol(slow_symbol)
	list_symbol(range_symbol)
	
