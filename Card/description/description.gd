extends Spatial

onready var desrip_scene = $Viewport/description
onready var image = $Viewport/description/Image
onready var card_name = $Viewport/description/card_name
onready var symbols_list = $Viewport/description/detailed_symbols
onready var cost = $Viewport/description/Cost/count
onready var health = $Viewport/description/Health/count
onready var attack = $Viewport/description/Attack/count
onready var symbol_scene = preload("res://Card/description/one_symbol.tscn")

var len_between_symbols = 90
var x_pos = 0

var pos_image_card = Vector2(200, 230)
var scale_image_card = Vector2(1.7, 2.3)

onready var viewport = $Viewport

#func _unhandled_input(event):
	# if event is InputEventMouseButton:
	#	var mouse_button_event := event as InputEventMouseButton
	#	if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
#	viewport.input(event)

func draw_symbols(one_symbol, sym_id):
	var path = one_symbol.symbol_texture
	var symb_desc = symbol_scene.instance()
	var img_texture  = load(path)
	symb_desc.get_node("name").text = one_symbol.symbol_name
	symb_desc.get_node("sprite").texture = img_texture
	symb_desc.get_node("details").text = one_symbol.symbol_description
	symb_desc.translate(Vector2(0, sym_id * len_between_symbols))
	symbols_list.add_child(symb_desc)

func set_desription(card_config):
	# image = set_image(...)
	card_name.text = card_config.card_name
	# исправить на логику костей/крови
	if card_config.play_cost != null:
		cost.text = String(card_config.play_cost.energy)
	health.text = String(card_config.health)
	attack.text = String(card_config.power)
	image.texture = load(card_config.card_texture)
	# image.translate(pos_image_card)
	#image.scale = scale_image_card
	
	for prev_symbol in symbols_list.get_children():
		symbols_list.remove_child(prev_symbol)
		prev_symbol.queue_free()
	
	var cur_symb_id = 0
	for symbol in card_config.common_symbols:
		self.draw_symbols(symbol, cur_symb_id)
		cur_symb_id += 1
	
	for symbol in card_config.mod_symbols:
		self.draw_symbols(symbol, cur_symb_id)
		cur_symb_id += 1
	
	for symbol in card_config.effect_symbols:
		self.draw_symbols(symbol, cur_symb_id)
		cur_symb_id += 1
	pass


func _on_Button_tmp_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			self.hide()
	pass # Replace with function body.
