extends "res://Map/Location/location.gd"

onready var board := $board
onready var player_1 := $human_player_1
onready var player_2 := $temp_human_player_2
onready var bell := $bell
onready var fight_state := $fight_state
onready var fight_loger := $fight_loger


var TurnState := preload("res://Fight/fight_state.gd").TurnState

func initialize(deck_config , inventory_config , params : Dictionary):
	.initialize(deck_config , inventory_config , params)
	$Camera.make_current()
	board.initialize()
	player_1.initialize(fight_state, board, bell, self.deck_config, 1, self.params)
	player_2.initialize(fight_state, board, bell, self.deck_config, 2, self.params)
	start()

func start():
	fight_state.loop_number = 1
	fight_state.player_1_health = 5
	fight_state.player_2_health = 5
	fight_state.set_state(TurnState.DRAW_CARDS, 1)


func _on_button_exit_to_map_pressed():
	emit_signal("return_to_map")
