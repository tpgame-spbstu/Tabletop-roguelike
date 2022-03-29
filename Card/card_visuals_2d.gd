extends Control

onready var card_name_label = $card_name_label
onready var card_params_label = $card_params_label

func update_to_card(card):
	card_name_label.text = card.card_name
	var params_text = ""
	params_text += String(card.player)
	params_text += "\n"
	params_text += String(card.cost)
	params_text += "\n"
	params_text += String(card.symbols)
	params_text += "\n"
	params_text += String(card.health)
	params_text += "\n"
	params_text += String(card.power)
	params_text += "\n"
	params_text += String(card.attack_range)
	params_text += "\n"
	params_text += String(card.attack_type)
	params_text += "\n"
	params_text += String(card.move_cost)
	card_params_label.text = params_text
