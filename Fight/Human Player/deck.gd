extends Spatial

# Deck node - container for cards in deck

signal deck_click(deck, card)

signal deck_mouse_entered(deck, card)

signal deck_mouse_exited(deck, card)

onready var highlighter := $deck_highlight
onready var card_counter := $cards_counter

onready var deck_list := $deck_list

var TurnState := preload("res://Fight/fight_state.gd").TurnState
var CardScene := preload("res://Card/card.tscn") as PackedScene
var fight_global_signals
var fight_state
var human_player_state

export(int) var collision_layer_index = 5

var spacer_width = 0.02 #space between cards in deck
var max_visible_cards_count = 10 #
var dummy_count = 7
var dummy_card_config = BaseCardsManager.get_card_config_copy("Пень")


func _ready():
	$Area.set_collision_layer_bit(collision_layer_index - 1, true)


func initialize(fight_global_signals, fight_state, human_player_state, deck_config, shuffle_seed, owner_number):
	self.fight_global_signals = fight_global_signals
	self.fight_state = fight_state
	self.human_player_state = human_player_state
	
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, owner_number), 
		self, "_on_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.PLACE_AND_MOVE, owner_number), 
		self, "_on_place_and_move_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.ATTACK, owner_number), 
		self, "_on_attack_enter")
	human_player_state.connect("extra_draws_count_changed", self, "_on_extra_draws_count_changed")
	
	if deck_config == null:
		for i in range(dummy_count):
			add_new_card_to_bottom(dummy_card_config, owner_number)
		card_counter.set_value(get_card_count())
		return
	
	var local_card_list = deck_config.cards.duplicate() as Array
	rand_seed(shuffle_seed)
	local_card_list.shuffle()
	
	for card_config in local_card_list:
		add_new_card_to_bottom(card_config, owner_number)
	card_counter.set_value(get_card_count())


func add_new_card_to_bottom(card_config, owner_number):
	var new_card = CardScene.instance()
	deck_list.add_child(new_card)
	var visible_cards_count = deck_list.get_child_count()
	if(visible_cards_count > max_visible_cards_count):
		visible_cards_count = max_visible_cards_count
	new_card.translate(Vector3(0, (-new_card.get_size().y - spacer_width) * visible_cards_count, 0))
	new_card.initialize(card_config, owner_number, fight_global_signals, fight_state)

func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			var card = get_top_card_or_null()
			emit_signal("deck_click", self, card)


func get_card_count():
	return deck_list.get_child_count()
	
func get_top_card_or_null():
	var card = null
	if get_card_count() != 0:
		card = deck_list.get_child(deck_list.get_child_count()-1)
	return card


func highlight():
	highlighter.highlight()


func is_mouse_hovered():
	var cam = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	return RaycastUtils.is_mouse_hovered_on_area($Area, collision_layer_index, cam, get_world(), mouse_pos)


var HighlightState := preload("res://Fight/Human Player/deck_highlight.gd").HighlightState


func update_hover(is_hovered = null):
	if is_hovered == null:
		is_hovered = is_mouse_hovered()
	var idle_state;
	if get_card_count() == 0:
		idle_state = HighlightState.SPIKE
	else:
		idle_state = HighlightState.HIDEN
	if fight_state.active_player_number != 1:
		highlighter.set_state(idle_state)
		return
	match fight_state.turn_state:
		TurnState.PLACE_AND_MOVE:
			if get_card_count() == 0:
				 highlighter.set_spike()
			else:
				if is_hovered:
					if human_player_state.extra_draws_count > 0:
						highlighter.set_cost()
					else:
						highlighter.set_cant_take()
				else:
					highlighter.set_hiden()
		TurnState.DRAW_CARDS:
			if get_card_count() == 0:
				if is_hovered:
					highlighter.set_take_damage()
				else:
					highlighter.set_spike()
			else:
				if is_hovered:
					highlighter.set_take_one()
				else:
					highlighter.set_highlight()
		_:
			highlighter.set_state(idle_state)
	
	var card = null
	if deck_list.get_child_count() != 0:
		card = deck_list.get_child(0)
	if is_hovered:
		emit_signal("deck_mouse_entered", self, card)
	else:
		emit_signal("deck_mouse_exited", self, card)


func remove_card(card):
	deck_list.remove_child(card)
	card_counter.set_value(get_card_count())


func _on_Area_mouse_entered():
	update_hover(true)


func _on_Area_mouse_exited():
	update_hover(false)


func _on_draw_cards_enter():
	update_hover()


func _on_place_and_move_enter():
	update_hover()


func _on_attack_enter():
	update_hover()


func _on_extra_draws_count_changed(count):
	update_hover()
