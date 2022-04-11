extends "res://location.gd"

onready var deck = $deck;
onready var card_scene = preload("res://Card/card.tscn")
onready var cell_scene = preload("res://Sacrifice_location/cell_sacrifice_loc.tscn")
onready var cell_from = $cell_from
onready var cell_to = $cell_to
onready var zero = $reference_frame_card
var cards_arr : Array
var init_poit

var cur_board_cell
var is_card_pressed = false
var is_place_pressed = false
var card_on_from = null
var card_on_to = null
var cur_card

func initialize(deck_config, inventory_config, params : Dictionary):
	.initialize(deck_config, inventory_config, params)
	self.fill_deck()
	pass

func move_card(board_cell, card_to_move, prev_board_cell):
	card_to_move.animation = LinMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.1, card_to_move)
	yield(card_to_move, "animation_ended")
	is_card_pressed = false
	is_place_pressed = false

func fill_deck():
	var step = 0
	for card_config in self.deck_config.cards:
		# Area -> Card / CollisionShape(box shape)
		var card = card_scene.instance()
		var cell = cell_scene.instance()
		var point0 = zero.translation
		cell.translate(point0 + Vector3(-step, 0, 0))
		cell.add_child(card)
		"""var collision_shape = CollisionShape.new()
		var box_shape = BoxShape.new()
		box_shape.extents = Vector3(0.455, 0.014, 0.454)
		collision_shape.shape = box_shape
		cell.add_child(collision_shape)"""
		
		deck.add_child(cell)
		cell.connect("input_event", self, "_on_card_input_event")
		card.initialize(card_config, 1)
		step += 1

func _on_card_input_event(cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			cur_card = cell.get_node("card")
			cur_board_cell = cell.get_node("cell")
			is_card_pressed = true
			pass

func _on_Area_1_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			if is_card_pressed:
				if card_on_from != null:
					var cell_first_pos = card_on_from.get_parent().get_node("cell")
					move_card(cell_first_pos, card_on_from, cell_from)
					
				move_card(cell_from, cur_card, cur_board_cell)
				card_on_from = cur_card
				pass

func _on_Area_2_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			if is_card_pressed:
				if card_on_to != null:
					var cell_first_pos = card_on_to.get_parent().get_node("cell")
					move_card(cell_first_pos, card_on_to, cell_to)
				
				move_card(cell_to, cur_card, cur_board_cell)
				card_on_to = cur_card
				pass

func choice_symbol_to_move(card_config):
	for symb_name in card_config.common_symbols.keys():
		# заглушка
		if(card_config.common_symbols[symb_name].can_be_transferred):
			return card_config.common_symbols[symb_name]
	return null
	
func get_symbols_by_card(card):
	return card.get_node("card_visuals/Viewport/card_visuals_2d").get_node("Symbols").get_children()

var symbol_script = preload("res://Card/card_visuals_2d.gd")

func move_symbols(config_from, config_to):
	var symbol = choice_symbol_to_move(config_from)
	config_from.common_symbols.erase(symbol.symbol_name)
	config_to.mod_symbols[symbol.symbol_name] = symbol
	
	# move symbols on real map
	symbol = choice_symbol_to_move(card_on_from)
	card_on_from.common_symbols.erase(symbol.symbol_name)
	card_on_to.mod_symbols[symbol.symbol_name] = symbol
	card_on_from.card_visuals_2d.update_to_card(card_on_from)
	card_on_to.card_visuals_2d.update_to_card(card_on_to)
	
	card_on_from.queue_free()
	self.deck_config.cards.erase(config_from)
	pass

func _on_Button_pressed():
	var config_on_from
	var config_on_to
	for card_conf in self.deck_config.cards:
		if card_conf.card_name == card_on_from.card_name:
			config_on_from = card_conf
			
	for card_conf in self.deck_config.cards:
		if card_conf.card_name == card_on_to.card_name:
			config_on_to = card_conf
			
	move_symbols(config_on_from, config_on_to)
	pass
