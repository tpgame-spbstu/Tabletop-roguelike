extends "res://Fight/fight_input_manager.gd"


onready var focus_shade := $focus_shade
onready var tutorial_ui := $tutorial_ui
onready var resources_focus_point := $resources_focus_point
onready var enemy_preview_focus_point := $enemy_preview_focus_point
onready var player_base_focus_point := $player_base_focus_point
onready var enemy_base_focus_point := $enemy_base_focus_point
var hand
var main_deck
var dummy_deck
var gong

var _text_list := [
	"[center]Это обучение 1[/center]",
	"[center]Это обучение 2[/center]",
	"[center]Это обучение 3[/center]",
	"[center]Это обучение 4[/center]",
	"[center]Это обучение 5[/center]",
	"[center]Это обучение 6[/center]",
	"[center]Это обучение 7[/center]",
	"[center]Это обучение 8[/center]",
	"[center]Это обучение 9[/center]",
	"[center]Это обучение 10[/center]",
	"[center]Это обучение 11[/center]",
	"[center]Это обучение 12[/center]",
	"[center]Это обучение 13[/center]",
	"[center]Это обучение 14[/center]",
	
	]

var _tutorial_state : GDScriptFunctionState
var _text_index = 0
var _awaited_data_mask := {}
var _awaited_type := ""

class FightEvent:
	var type: String
	var data: Dictionary
	
	
	func _init(type, data= {}):
		self.type = type
		self.data = data


var TurnState := preload("res://Fight/fight_state.gd").TurnState


func initialize(fight_state, fight_global_signals, board, human_player):
	.initialize(fight_state, fight_global_signals, board, human_player)
	hand = human_player.get_node("hand")
	main_deck = human_player.get_node("main_deck")
	dummy_deck = human_player.get_node("dummy_deck")
	gong = human_player.get_node("gong")
	
	fight_state.connect("player_1_draw_cards_enter", self, "_on_draw_cards_enter")
	
	fight_global_signals.connect("card_drawn", self, "_on_card_drawn")
	fight_global_signals.connect("card_played", self, "_on_card_played")
	fight_global_signals.connect("card_moved", self, "_on_card_moved")
	
	tutorial_ui.connect("next_button_pressed", self, "_on_next_button_pressed")
	
	_tutorial_state = _tutorial()
	_tutorial_state.connect("completed", self, "_on_tutorial_completed")


func _next_text():
	if not _text_index in range(_text_list.size()):
		return ""
	var text = _text_list[_text_index]
	_text_index += 1
	return text


func is_awaited_input_request(resume_input):
	if resume_input == null:
		return false
	if not resume_input is InputRequest:
		return false
	var input_request = resume_input as InputRequest
	if input_request.type != _awaited_type:
		return false
	for mask_key in _awaited_data_mask.keys():
		if not input_request.data.has(mask_key):
			return false
		if input_request.data[mask_key] != _awaited_data_mask[mask_key]:
			return false
	return true


func is_awaited_fight_event(resume_input):
	if resume_input == null:
		return false
	if not resume_input is FightEvent:
		return false
	var fight_event = resume_input as FightEvent
	if fight_event.type != _awaited_type:
		return false
	for mask_key in _awaited_data_mask.keys():
		if not fight_event.data.has(mask_key):
			return false
		if fight_event.data[mask_key] != _awaited_data_mask[mask_key]:
			return false
	return true


func _tutorial():
	var resume_input
	focus_shade.show()
	tutorial_ui.show_text(_next_text(), true)
	focus_shade.global_transform.origin = resources_focus_point.global_transform.origin
	_awaited_type = "next_button_pressed"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	
	tutorial_ui.show_text(_next_text(), true)
	focus_shade.global_transform.origin = enemy_preview_focus_point.global_transform.origin
	_awaited_type = "next_button_pressed"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	
	tutorial_ui.show_text(_next_text(), true)
	focus_shade.global_transform.origin = player_base_focus_point.global_transform.origin
	focus_shade.scale = player_base_focus_point.scale
	_awaited_type = "next_button_pressed"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	focus_shade.scale = Vector3.ONE
	
	tutorial_ui.show_text(_next_text(), true)
	focus_shade.global_transform.origin = enemy_base_focus_point.global_transform.origin
	focus_shade.scale = enemy_base_focus_point.scale
	_awaited_type = "next_button_pressed"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	focus_shade.scale = Vector3.ONE
	
	tutorial_ui.show_text(_next_text())
	focus_shade.global_transform.origin = main_deck.global_transform.origin
	_awaited_type = "deck_click"
	_awaited_data_mask = {"deck": main_deck}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	
	_awaited_type = "card_drawn"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	var target_card = resume_input.data["card"]
	
	tutorial_ui.show_text(_next_text())
	focus_shade.global_transform.origin = target_card.global_transform.origin
	focus_shade.show()
	_awaited_type = "hand_select_card_click"
	_awaited_data_mask = {"card": target_card}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	
	tutorial_ui.show_text(_next_text())
	var target_board_cell = board.get_board_cell(0, 1)
	focus_shade.global_transform.origin = target_board_cell.global_transform.origin
	_awaited_type = "board_correct_play_click"
	_awaited_data_mask = {"board_cell": target_board_cell}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	
	_awaited_type = "card_played"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	
	tutorial_ui.show_text(_next_text())
	focus_shade.global_transform.origin = target_card.global_transform.origin
	_awaited_type = "board_correct_select_move_click"
	_awaited_data_mask = {"board_cell": target_board_cell}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	
	tutorial_ui.show_text(_next_text())
	target_board_cell = board.get_board_cell(1, 1)
	focus_shade.global_transform.origin = target_board_cell.global_transform.origin
	_awaited_type = "board_correct_move_click"
	_awaited_data_mask = {"board_cell": target_board_cell}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	
	_awaited_type = "card_moved"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()
	
	tutorial_ui.show_text(_next_text())
	focus_shade.global_transform.origin = gong.global_transform.origin
	_awaited_type = "bell_click"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_input_request(resume_input):
		resume_input = yield()
	resume_input.allow()
	focus_shade.hide()
	tutorial_ui.hide()
	
	_awaited_type = "draw_cards_enter"
	_awaited_data_mask = {}
	resume_input = yield()
	while not is_awaited_fight_event(resume_input):
		resume_input = yield()


func _on_draw_cards_enter():
	var fight_event = FightEvent.new("draw_cards_enter")
	_on_fight_event(fight_event)


func _on_card_drawn(deck, card):
	var fight_event = FightEvent.new("card_drawn", {"deck": deck, "card": card})
	_on_fight_event(fight_event)


func _on_card_played(board_cell, card):
	var fight_event = FightEvent.new("card_played", {"board_cell": board_cell, "card": card})
	_on_fight_event(fight_event)


func _on_card_moved(prev_board_cell, cur_board_cell, card):
	var fight_event = FightEvent.new("card_moved", 
		{"prev_board_cell": prev_board_cell, "cur_board_cell": cur_board_cell, "card": card})
	_on_fight_event(fight_event)


func _on_next_button_pressed():
	var fight_event = FightEvent.new("next_button_pressed")
	_on_fight_event(fight_event)


func _on_fight_event(fight_event: FightEvent):
	if _tutorial_state is GDScriptFunctionState and _tutorial_state.is_valid():
		_tutorial_state = _tutorial_state.resume(fight_event)


func _on_input_requested(input_request: InputRequest):
	if _tutorial_state is GDScriptFunctionState and _tutorial_state.is_valid():
		_tutorial_state = _tutorial_state.resume(input_request)
	else:
		._on_input_requested(input_request)


func _on_tutorial_completed():
	pass
