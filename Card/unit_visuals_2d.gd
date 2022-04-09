extends Control

onready var card_name_label = $Card_name
onready var card_params_label = $card_params_label
onready var health_label = $Health/count
onready var attack_label = $Attack/count
onready var image = $Image
onready var symbols = $Symbols

var y_pos = 274
var positions_symbols = [Vector2(70, y_pos), Vector2(200, y_pos), Vector2(330, y_pos)]

func draw_symbols(path, sym_id):
	var image = Image.new()
	var img_texture  = ImageTexture.new()
	var symb = Sprite.new()
	image.load(path)
	img_texture.create_from_image(image)
	symb.texture = img_texture
	symb.translate(positions_symbols[sym_id])
	symb.scale = Vector2(2, 2)
	symbols.add_child(symb)

func update_to_card(card):
	card_name_label.text = card.card_name
	var params_text = ""
	params_text += String(card.owner_number)
	health_label.text = String(card.health)
	attack_label.text = String(card.power)
	var cur_symb_id = 0
	for symbol_name in card.common_symbols.keys():
		var path = card.common_symbols[symbol_name].symbol_image
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
		
	for symbol_name in card.mod_symbols.keys():
		var path = card.mod_symbols[symbol_name].symbol_image
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
