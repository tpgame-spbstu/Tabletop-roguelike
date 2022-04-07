extends Control

onready var card_name_label = $card_name_label
onready var card_params_label = $card_params_label

func update_to_card(card):
	card_name_label.text = card.card_name
	var params_text = ""
	params_text += String(card.owner_number)
	params_text += "\n"
	params_text += String(card.play_cost.energy)
	params_text += "\n"
	params_text += String(card.health)
	params_text += "\n"
	params_text += String(card.power)
	params_text += "\n"
	for symbol_name in card.common_symbols.keys():
		params_text += symbol_name + ", "
	params_text += "\n"
	for symbol_name in card.mod_symbols.keys():
		params_text += symbol_name + ", "
	card_params_label.text = params_text
