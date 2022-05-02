extends Node

# SymbolManager class - library of preloaded symbols, stored by name

var symbol_dictionary : Dictionary

var Weakening := preload("res://Symbols/weakening.gd")
var WeakeningEffect := preload("res://Symbols/weakening_effect.gd")


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
	var fast_symbol = Symbol.new("Быстрый", "res://Symbols/Textures/speed.tres", "Передвижение дешевле на 1 энергию.", true, true)
	var slow_symbol = Symbol.new("Медленный", "res://Symbols/Textures/Icon46.png", "Передвижение дороже на 1 энергию.", true, true)
	var range_symbol = Symbol.new("Стрелок", "res://Symbols/Textures/Icon42.png", "Атака на одну клетку дальше.", true, true)
	var counterattack_symbol = Symbol.new("Ответный удар", "res://Symbols/Textures/Icon14.png", "Если карта выживает после получения урона, то проводит контратаку.", true, true)
	var weakening_symbol = Weakening.new("Ослабление", "res://Symbols/Textures/Icon48.png", "Атака юнита напротив ослаблена на 1.", true, true)
	var weakening_effect_symbol = WeakeningEffect.new("Слабость", "res://Symbols/Textures/Icon41.png", "Атака ослаблена на 1.", true, true)
	list_symbol(fast_symbol)
	list_symbol(slow_symbol)
	list_symbol(range_symbol)
	list_symbol(counterattack_symbol)
	list_symbol(weakening_symbol)
	list_symbol(weakening_effect_symbol)
	
