extends Node

# BaseCardsManager class - library of preloaded cards, stored by name

var cards_dictionary : Dictionary
var CardConfig := preload("res://Card/card_config.gd")


func list_card_config(card_config):
	assert(!cards_dictionary.has(card_config.card_name))
	cards_dictionary[card_config.card_name] = card_config


func get_card_config(card_name):
	assert(cards_dictionary.has(card_name))
	return cards_dictionary[card_name]


func get_card_config_copy(card_name):
	assert(cards_dictionary.has(card_name))
	return cards_dictionary[card_name].get_copy()


func _ready():
	list_card_config(CardConfig.new(
		"Пень", 
		"res://Card/Textures/Forest Sprout.png", 
		Cost.new(0, 0, 0), 
		[], 
		[], 
		[], 
		0, 1))
	
	list_card_config(CardConfig.new(
		"Жук", 
		"res://Card/Textures/Insects Roach.png", 
		Cost.new(0, 0, 0), 
		[], 
		[], 
		[], 
		1, 1))
	
	list_card_config(CardConfig.new(
		"Жук быстрый", 
		"res://Card/Textures/Insects Bee.png", 
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("fast")], 
		[], 
		[], 
		1, 1))
	
	list_card_config(CardConfig.new(
		"Жук медленный", 
		"res://Card/Textures/Insects Black Ant Protector.png", 
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("slow")], 
		[], 
		[], 
		3, 3))
	
	list_card_config(CardConfig.new(
		"Жук средний", 
		"res://Card/Textures/Insect Red Ant Knight.png", 
		Cost.new(1, 0, 0), 
		[], 
		[], 
		[], 
		1, 2))
	
	list_card_config(CardConfig.new(
		"Жук ослабляющий", 
		"res://Card/Textures/Forest Spider.png", 
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("weakening")], 
		[], 
		[], 
		1, 2))
	
	list_card_config(CardConfig.new(
		"Жук котратаки", 
		"res://Card/Textures/Insects Hell Mantis.png", 
		Cost.new(4, 0, 0), 
		[SymbolManager.get_symbol("counterattack")], 
		[], 
		[], 
		1, 3))
	
	list_card_config(CardConfig.new(
		"Жук дальнобойный", 
		"res://Card/Textures/Insects Black Ant Archer.png", 
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("range")], 
		[], 
		[], 
		2, 1))
	
	list_card_config(CardConfig.new(
		"Банши", 
		"res://Card/Textures/Darkness Banshee.png", 
		Cost.new(4, 0, 0), 
		[SymbolManager.get_symbol("weakening"), SymbolManager.get_symbol("fast")], 
		[], 
		[], 
		2, 1))
	
	list_card_config(CardConfig.new(
		"Мандрагора", 
		"res://Card/Textures/Earth Mandrake.png", 
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("weakening")], 
		[], 
		[], 
		1, 1))
	
	list_card_config(CardConfig.new(
		"Мумия", 
		"res://Card/Textures/Egypt Mummy A.png",
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("slow"), SymbolManager.get_symbol("counterattack")], 
		[], 
		[], 
		2, 2))
	
	list_card_config(CardConfig.new(
		"Жрец тьмы", 
		"res://Card/Textures/flayer_01.png",
		Cost.new(3, 0, 0), 
		[SymbolManager.get_symbol("slow"), SymbolManager.get_symbol("weakening")], 
		[], 
		[], 
		3, 1))
	
	list_card_config(CardConfig.new(
		"Гоблин-лучник", 
		"res://Card/Textures/Goblin Archer.png",
		Cost.new(2, 0, 0), 
		[SymbolManager.get_symbol("range")], 
		[], 
		[], 
		1, 1))
	
	
