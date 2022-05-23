extends Control


onready var description_card := $description_card


signal final_status_return_to_map_pressed()
signal debug_return_to_map_pressed()
signal return_to_main_menu()


func show_card_desription(card):
	if card == null:
		return
	description_card.set_desription(card.card_config)
	description_card.show()
	pass


func _on_fight_state_loop_number_changed(loop_number):
	$loop.text = loop_number as String


func _on_fight_state_player_1_draw_cards_enter():
	$Status1.margin_left = -120
	$Status1.text = "Взятие карты"
	$Status1.show()
	$Status2.hide()


func _on_fight_state_player_1_attack_enter():
	$Status1.margin_left = -74
	$Status1.text = "Атака"


func _on_fight_state_player_1_place_and_move_enter():
	$Status1.margin_left = -125
	$Status1.text = "Выставление"


func _on_fight_state_player_2_draw_cards_enter():
	$Status2.show()
	$Status1.hide()


func _on_loop_mouse_entered():
	$loop_label.show()


func _on_loop_mouse_exited():
	$loop_label.hide()


func show_final_status(message):
	$Final_status.show()
	$Final_status/RichTextLabel.bbcode_text = message
	$Final_status/return_to_map.show()


func _on_fight_state_player_2_attack_enter():
	pass # Replace with function body.


func _on_fight_state_player_2_place_and_move_enter():
	pass # Replace with function body.


func _on_button_exit_to_map_pressed():
	emit_signal("debug_return_to_map_pressed")


func _on_final_status_return_to_map_pressed():
	emit_signal("final_status_return_to_map_pressed")


func _on_fight_state_player_1_win_enter():
	show_final_status("[center]Победа[/center]")


func _on_fight_state_player_2_win_enter():
	show_final_status("[center]Проигрыш[/center]")


func _on_button_exit_to_main_menu_pressed():
	emit_signal("return_to_main_menu")
