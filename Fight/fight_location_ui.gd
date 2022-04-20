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
	$HP1.text = player_1_health as String


func _on_fight_state_player_2_health_changed(player_2_health):
	$HP2.text = player_2_health as String


func _on_fight_state_player_1_draw_cards_enter():
	$Status1.text = "Card selection"
	$Status1.show()
	$Status2.hide()
	$Bones.show()
	$Energy.show()
	$card.text = "2"
	$card.show()


func _on_fight_state_player_1_attack_enter():
	$Status1.text = "Attack"


func _on_fight_state_player_1_place_and_move_enter():
	$Status1.text = "Place and move"


func _on_fight_state_player_2_draw_cards_enter():
	$Status2.show()
	$Status1.hide()
	$Bones.hide()
	$Energy.hide()
	$card.hide()


func _on_human_player_state_bones_changed(bones):
	$Bones.text = bones as String


func _on_human_player_state_energy_changed(energy):
	$Energy.text = energy as String


func _on_human_player_state_extra_draws_count_changed(extra_draws_count):
	$card.text = extra_draws_count as String
