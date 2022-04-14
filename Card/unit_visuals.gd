extends Spatial

onready var card_name_label = $Viewport/unit_visuals_2d/Card_name
onready var health_label = $Viewport/unit_visuals_2d/Health/count
onready var attack_label = $Viewport/unit_visuals_2d/Attack/count
onready var image = $Viewport/unit_visuals_2d/Image
onready var symbols = $Viewport/unit_visuals_2d/Symbols
onready var platform = $platform
const PLAYER_1 = 1
const PLAYER_2 = 2

var y_pos = 274
var positions_symbols = [Vector2(70, y_pos), Vector2(200, y_pos), Vector2(330, y_pos)]

var card_config


func initialize(card_config, owner_number = PLAYER_1):
	self.card_config = card_config
	self.update()
	self.set_owner_number(owner_number)


func set_owner_number(owner_number):
	var newMaterial = SpatialMaterial.new()
	newMaterial.albedo_color = Color("09165d") # синий
	if(owner_number == PLAYER_2):
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


func update():
	card_name_label.text = card_config.card_name
	health_label.text = String(card_config.health)
	attack_label.text = String(card_config.power)
	for prev_symbol in symbols.get_children():
		symbols.remove_child(prev_symbol)
		prev_symbol.queue_free()
	var cur_symb_id = 0
	
	for symbol in card_config.common_symbols:
		if !symbol.is_visible:
			continue
		var path = symbol.symbol_texture
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
		
	for symbol in card_config.mod_symbols:
		if !symbol.is_visible:
			continue
		var path = symbol.symbol_texture
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
		
	for symbol in card_config.effect_symbols:
		if !symbol.is_visible:
			continue
		var path = symbol.symbol_texture
		self.draw_symbols(path, cur_symb_id)
		cur_symb_id += 1
