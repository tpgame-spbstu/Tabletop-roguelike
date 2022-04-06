extends Spatial

signal deck_click(deck, card)

onready var deck_list := $deck_list
var CardScene := preload("res://Card/card.tscn") as PackedScene

func initialize(fight_location, deck_config, shuffle_seed):
	
	var local_card_list = deck_config.cards.duplicate() as Array
	rand_seed(shuffle_seed)
	local_card_list.shuffle()
	
	for card_config in local_card_list:
		add_new_card_to_bottom(card_config)


func add_new_card_to_bottom(card_config):
	var new_card = CardScene.instance()
	deck_list.add_child(new_card)
	new_card.initialize(card_config, 1)

func _on_Area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT :
			var card = null
			if deck_list.get_child_count() != 0:
				card = deck_list.get_child(0)
			emit_signal("deck_click", self, card)
