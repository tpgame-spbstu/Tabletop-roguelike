extends "res://Fight/fight_input_manager.gd"


var tutorial_state : GDScriptFunctionState


var TurnState := preload("res://Fight/fight_state.gd").TurnState


func initialize(fight_state, player_1):
	.initialize(fight_state, player_1)
	tutorial_state = _tutorial()
	tutorial_state.connect("completed", self, "_on_tutorial_completed")


func _tutorial():
	while true:
		var input_request = yield() as InputRequest
		if input_request.type == "deck_click":
			if input_request.data["deck"].name == "main_deck":
				input_request.allow()
				break
	while true:
		var input_request = yield() as InputRequest
		if input_request.type == "deck_click":
			if input_request.data["deck"].name == "dummy_deck":
				input_request.allow()
				break


func _on_input_requested(input_request: InputRequest):
	if tutorial_state is GDScriptFunctionState and tutorial_state.is_valid():
		tutorial_state = tutorial_state.resume(input_request)


func _on_tutorial_completed():
	fight_state.set_state(TurnState.WIN, 1)
