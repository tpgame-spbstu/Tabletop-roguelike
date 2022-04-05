extends Control

onready var card_name_label = $card_name_label
onready var card_params_label = $card_params_label

func update_to_card(card):
	card_name_label.text = card.card_name
	var params_text = ""
	params_text += String(card.is_owned_by_player)
	params_text += "\n"
	params_text += String(card.play_cost.energy)
	params_text += "\n"
	params_text += String(card.symbols.get_children())
	params_text += "\n"
	params_text += String(card.health)
	params_text += "\n"
	params_text += String(card.power)
	card_params_label.text = params_text
