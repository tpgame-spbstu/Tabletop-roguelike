extends Control

onready var card_name_label = $Card_name
onready var health_label = $Health/count
onready var attack_label = $Attack/count
onready var image = $Image
onready var symbols = $Symbols
onready var platform = get_node("../../platform")
const PLAYER_1 = 1
const PLAYER_2 = 2

var y_pos = 274
var positions_symbols = [Vector2(70, y_pos), Vector2(200, y_pos), Vector2(330, y_pos)]

func set_platform_color(card_owner):
	var newMaterial = SpatialMaterial.new()
	newMaterial.albedo_color = Color("09165d")
	if(card_owner == PLAYER_2):
		platform.material_override = newMaterial
	else:
		pass

func draw_symbols(path, sym_id):
	var img_texture  = load(path)
	var symb = Sprite.new()
	symb.texture = img_texture
	symb.translate(positions_symbols[sym_id])
	symb.scale = Vector2(2, 2)
	symbols.add_child(symb)

func update_to_card(card):
	card_name_label.text = card.card_name
	self.set_platform_color(card.owner_number)
	health_label.text = String(card.health)
	attack_label.text = String(card.power)
	for prev_symbol in symbols.get_children():
		symbols.remove_child(prev_symbol)
		prev_symbol.queue_free()
	var cur_symb_id = 0
	for symbol_name in card.common_symbols.keys():
		var path = card.common_symbols[symbol_name].symbol_texture
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
		
	for symbol_name in card.mod_symbols.keys():
		var path = card.mod_symbols[symbol_name].symbol_texture
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
