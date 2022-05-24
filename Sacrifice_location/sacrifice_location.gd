extends "res://Map/Location/location.gd"

onready var deck = $deck;
onready var selector = $selector
onready var cell_scene = preload("res://Sacrifice_location/cell_sacrifice_loc.tscn")
onready var cell_from = $cell_from
onready var cell_to = $cell_to
onready var zero = $reference_frame_card
var card_visuals_scene := preload("res://Card/card_visuals.tscn") as PackedScene
var cards_arr : Array
var init_poit

var cur_board_cell
var is_card_pressed = false
var is_place_pressed = false
var card_on_from = null
var card_on_to = null
var cur_card
var is_sacrifice = false

func initialize(deck_config, inventory_config, params : Dictionary):
	.initialize(deck_config, inventory_config, params)
	$Camera.make_current()
	self.fill_deck()
	pass

func move_card(board_cell, card_to_move, prev_board_cell):
	var animation = LinMoveAnimation.new(prev_board_cell.global_transform, 
		board_cell.global_transform, 0.1, card_to_move)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	is_card_pressed = false
	is_place_pressed = false

func fill_deck():
	var scal = 0.5
	var step = 0
	for card_config in self.deck_config.cards:
		# Area -> Card / CollisionShape(box shape)
		var card = card_visuals_scene.instance()
		var cell = cell_scene.instance()
		var point0 = zero.translation
		cell.translate(point0 + Vector3(-step * scal, 0, 0))
		cell.add_child(card)
		
		deck.add_child(cell)
		cell.connect("input_event", self, "_on_card_input_event")
		card.initialize(card_config)
		step += 1

func _on_card_input_event(cell, event):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT:
			cur_card = cell.get_node("card_visuals")
			cur_board_cell = cell.get_node("cell")
			is_card_pressed = true
			selector.global_transform = cur_card.global_transform
			selector.show()
			pass
		elif mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_RIGHT:
			# добавить подробное описание
			pass

func _on_Area_1_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		selector.hide()
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
		selector.hide()
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
	var symbols = []
	for symbol_list in [card_config.common_symbols, card_config.mod_symbols, card_config.effect_symbols]:
		for symbol in symbol_list:
			if(symbol.can_be_transferred):
				symbols.append(symbol)
	return symbols
	
func get_symbols_by_card(card):
	return card.get_node("card_visuals/Viewport/card_visuals_2d").get_node("Symbols").get_children()


func move_symbols(config_from, config_to):
	var symbols = choice_symbol_to_move(config_from)
	for symbol in symbols:
		config_to.mod_symbols.append(symbol)
	
	card_on_from.update()
	card_on_to.update()
		
	card_on_from.queue_free()
	self.deck_config.cards.erase(config_from)
	pass

func _on_Button_pressed():
	if card_on_from == null or card_on_to == null:
		return
	var config_on_from = card_on_from.card_config
	var config_on_to = card_on_to.card_config
			
	move_symbols(config_on_from, config_on_to)
	end_of_sacrifice()
	$Sacrifice.hide()
	is_sacrifice = true
	pass

func _on_Return_to_map_pressed():
	emit_signal("return_to_map")


func end_of_sacrifice():
	for card in $deck.get_children():
		card.hide()

	card_on_to.get_parent().show()
	var spatial = card_on_to
	spatial.scale = card_on_to.scale * 2.8
	spatial.translate(Vector3(0.3, 0.6, -0.4))
	# spatial.rotate_x(-PI/6)
	pass
	
	
func _process(delta):
	if is_sacrifice:
		# добавить анимацию там, поворот мб
		# card_on_to.rotate_z(PI/100)
		pass
