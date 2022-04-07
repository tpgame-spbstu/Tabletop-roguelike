extends "res://location.gd"

onready var board := $board
onready var player_1 := $player_1
onready var player_2 := $player_2
onready var bell := $bell


var FightStateManager := preload("res://Fight/fight_state_manager.gd")


var fight_state


func initialize(deck_config , inventory_config , params : Dictionary):
	.initialize(deck_config , inventory_config , params)
	$Camera.make_current()
	board.initialize()
	fight_state = FightStateManager.new()
	player_1.initialize(fight_state, board, bell, self.deck_config, self.params)
	player_2.initialize(fight_state, board, bell, self.deck_config, self.params)
	fight_state.start()



func _on_button_exit_to_map_pressed():
	emit_signal("return_to_map")
