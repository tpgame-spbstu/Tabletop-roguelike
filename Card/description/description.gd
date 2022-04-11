extends Control

onready var image = $Image
onready var card_name = $card_name
onready var symbols_list = $detailed_symbols
onready var cost = $Cost/count
onready var health = $Health/count
onready var attack = $Attack/count
onready var symbol_scene = preload("res://Card/description/one_symbol.tscn")

var len_between_symbols = 90
var x_pos = 0

func draw_symbols(one_symbol, sym_id):
	var path = one_symbol.symbol_texture
	var symb_desc = symbol_scene.instance()
	var img_texture  = load(path)
	symb_desc.get_node("name").text = one_symbol.symbol_name
	symb_desc.get_node("sprite").texture = img_texture
	symb_desc.get_node("details").text = one_symbol.symbol_description
	symb_desc.translate(Vector2(0, sym_id * len_between_symbols))
	symbols_list.add_child(symb_desc)

func set_desription(card):
	# image = set_image(...)
	card_name.text = card.card_name
	cost.text = card.play_cost
	health.text = card.health
	attack.text = card.power
	
	for prev_symbol in symbols_list.get_children():
		symbols_list.remove_child(prev_symbol)
		prev_symbol.queue_free()
	
	var cur_symb_id = 0
	for symbol_name in card.common_symbols.keys():
		self.draw_symbols(card.common_symbols[symbol_name], cur_symb_id)
		cur_symb_id += 1
	
	for symbol_name in card.mod_symbols.keys():
		self.draw_symbols(card.common_symbols[symbol_name], cur_symb_id)
		cur_symb_id += 1
	
	pass
	
