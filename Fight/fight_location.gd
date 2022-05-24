extends "res://Map/Location/location.gd"

# FightLocation class - location for card fight

onready var board := $board
onready var player_1 := $human_player_1
onready var player_2 := $ai_player_2
onready var fight_state := $fight_state
onready var fight_loger := $fight_loger
onready var fight_global_signals := $fight_global_signals
onready var fight_location_ui := $fight_ui

var TurnState := preload("res://Fight/fight_state.gd").TurnState

func initialize(deck_config , inventory_config , params : Dictionary):
	.initialize(deck_config , inventory_config , params)
	$Camera.make_current()
	board.initialize(fight_global_signals)
	board.connect("board_right_click", self, "_on_board_right_click")
	player_1.initialize(fight_state, fight_global_signals, board, self.deck_config, 1, self.params)
	player_1.connect("show_card_description", self, "_on_show_card_description")
	player_2.initialize(fight_state, fight_global_signals, board, null, 2, self.params)
	player_2.connect("show_card_description", self, "_on_show_card_description")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.WIN, 1), 
		self, "_on_fight_state_player_1_win")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.WIN, 2), 
		self, "_on_fight_state_player_2_win")
	start()


func _on_board_right_click(board_cell, card):
	fight_location_ui.show_card_desription(card)


func _on_show_card_description(card):
	fight_location_ui.show_card_desription(card)


func start():
	fight_state.loop_number = 1
	fight_state.player_1_health = 5
	fight_state.player_2_health = 5
	fight_state.set_state(TurnState.DRAW_CARDS, 1)
	player_1.draw_start_cards()


func _on_fight_state_player_1_win():
	yield(fight_location_ui, "final_status_return_to_map_pressed")
	emit_signal("return_to_map", "win")


func _on_fight_state_player_2_win():
	yield(fight_location_ui, "final_status_return_to_map_pressed")
	emit_signal("return_to_map", "lose")


func _on_fight_ui_debug_return_to_map_pressed():
	emit_signal("return_to_map")


func _on_return_to_main_menu():
	emit_signal("return_to_map", "main_menu")
