extends Spatial

# Deck node - container for cards in deck

signal deck_click(deck, card)

onready var highlighter := $deck_highlight

onready var deck_list := $deck_list

var CardScene := preload("res://Card/card.tscn") as PackedScene
var fight_global_signals
var fight_state

var dummy_count = 7
var dummy_card_config := preload("res://Card/card_config.gd").new("Чучело", "res://Card/Textures/Insects Roach.png", Cost.new(0, 0, 0), [], [], [], 0, 1)

func initialize(fight_global_signals, fight_state, deck_config, shuffle_seed, owner_number):
	self.fight_global_signals = fight_global_signals
	self.fight_state = fight_state
	if deck_config == null:
		for i in range(dummy_count):
			add_new_card_to_bottom(dummy_card_config, owner_number)
		return
	
	var local_card_list = deck_config.cards.duplicate() as Array
	rand_seed(shuffle_seed)
	local_card_list.shuffle()
	
	for card_config in local_card_list:
		add_new_card_to_bottom(card_config, owner_number)


func add_new_card_to_bottom(card_config, owner_number):
	var new_card = CardScene.instance()
	deck_list.add_child(new_card)
	new_card.initialize(card_config, owner_number, fight_global_signals, fight_state)

func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			var card = null
			if deck_list.get_child_count() != 0:
				card = deck_list.get_child(0)
			emit_signal("deck_click", self, card)


func get_card_count():
	return deck_list.get_child_count()



func highlight():
	highlighter.highlight()


func cancel_highlight():
	highlighter.cancel_highlight()

