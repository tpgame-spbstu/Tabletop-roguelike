extends Control

onready var description_card_scene := preload("res://Card/description/description_main.tscn")
var description_card

func initialize(board, player):
	board.connect("board_right_click", self, "_on_board_right_click")
	player.hand.connect("hand_right_click", self, "_on_hand_right_click")
	description_card = description_card_scene.instance()
	description_card.hide()
	description_card.translate(Vector3(0, 0.4, 0))
	self.add_child(description_card)


func _on_board_right_click(board, card):
	if card == null:
		return
	description_card.set_desription(card.card_config)
	description_card.show()
	pass
	

func _on_hand_right_click(hand_cell, card):
	if card == null:
		return
	description_card.set_desription(card.card_config)
	description_card.show()
	pass


func _on_fight_state_loop_number_changed(loop_number):
	$loop.text = loop_number as String


func _on_fight_state_player_1_health_changed(player_1_health):
	$ColorRect/HP1.text = player_1_health as String


func _on_fight_state_player_2_health_changed(player_2_health):
	$ColorRect/HP2.text = player_2_health as String


func _on_fight_state_player_1_draw_cards_enter():
	$Status1.margin_left = -160
	$Status1.text = "Card selection"
	$Status1.show()
	$Status2.hide()
	$ColorRect/Bones.show()
	$ColorRect/Energy.show()
	$ColorRect/card.text = "2"
	$ColorRect/card.show()


func _on_fight_state_player_1_attack_enter():
	$Status1.margin_left = -74
	$Status1.text = "Attack"


func _on_fight_state_player_1_place_and_move_enter():
	$Status1.margin_left = -175
	$Status1.text = "Place and move"


func _on_fight_state_player_2_draw_cards_enter():
	$Status2.show()
	$Status1.hide()
	$ColorRect/Bones.hide()
	$ColorRect/Energy.hide()
	$ColorRect/card.hide()


func _on_human_player_state_bones_changed(bones):
	$ColorRect/Bones.text = bones as String


func _on_human_player_state_energy_changed(energy):
	$ColorRect/Energy.text = energy as String


func _on_human_player_state_extra_draws_count_changed(extra_draws_count):
	$ColorRect/card.text = extra_draws_count as String



func _on_HP2_mouse_entered():
	$ColorRect/HP_bot_label.show()


func _on_HP1_mouse_entered():
	$ColorRect/HP_player_label.show()


func _on_HP2_mouse_exited():
	$ColorRect/HP_bot_label.hide()


func _on_Energy_mouse_entered():
	$ColorRect/Energy_label.show()


func _on_Energy_mouse_exited():
	$ColorRect/Energy_label.hide()


func _on_HP1_mouse_exited():
	$ColorRect/HP_player_label.hide()


func _on_Bones_mouse_entered():
	$ColorRect/Bones_label.show()


func _on_Bones_mouse_exited():
	$ColorRect/Bones_label.hide()


func _on_card_mouse_entered():
	$ColorRect/Card_label.show()


func _on_card_mouse_exited():
	$ColorRect/Card_label.hide()


func _on_loop_mouse_entered():
	$loop_label.show()


func _on_loop_mouse_exited():
	$loop_label.hide()


func _on_fight_state_player_1_win():
	pass # Replace with function body.


func _on_fight_state_player_2_attack_enter():
	pass # Replace with function body.


func _on_fight_state_player_2_place_and_move_enter():
	pass # Replace with function body.


func _on_fight_state_player_2_win():
	pass # Replace with function body.
