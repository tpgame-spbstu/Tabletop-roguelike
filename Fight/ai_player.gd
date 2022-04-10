extends Spatial

onready var card_spawn_point := $card_spawn_point
var board
var fight_state
var fight_global_signals

var player_number

class CardQueueItem:
	var card_config
	var loop_number
	var column_index
	func _init(card_config, loop_number, column_index):
		self.card_config = card_config
		self.loop_number = loop_number
		self.column_index = column_index

var card_queue = []

var TurnState := preload("res://Fight/fight_state.gd").TurnState

var CardConfig := preload("res://Card/card_config.gd")
var Card := preload("res://Card/card.tscn")

func initialize(fight_state, fight_global_signals, board, player_number, params):
	self.fight_state = fight_state
	self.fight_global_signals = fight_global_signals
	self.board = board
	self.player_number = player_number
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.DRAW_CARDS, player_number), 
		self, "_on_draw_cards_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.PLACE_AND_MOVE, player_number), 
		self, "_on_place_and_move_enter")
	fight_state.connect(fight_state.get_turn_state_signal(TurnState.ATTACK, player_number), 
		self, "_on_attack_enter")
	card_queue.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], 1, 1), 1, 0))
	card_queue.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], 1, 1), 1, 1))
	card_queue.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], 1, 1), 1, 2))
	card_queue.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], 1, 1), 1, 3))
	
	

func _on_draw_cards_enter():
	fight_state.next_state()


func _on_place_and_move_enter():
	place_cards()
	move_cards()
	fight_state.next_state()
	


func place_cards():
	var i = 0
	var base_row_index = board.get_friendly_base_row_index(player_number)
	
	while i < card_queue.size() and card_queue[i].loop_number <= fight_state.loop_number:
		var target_cell = board.get_board_cell(base_row_index, card_queue[i].column_index)
		if target_cell.get_card_or_null() == null:
			var card_to_play = Card.instance()
			card_spawn_point.add_child(card_to_play)
			card_to_play.initialize(card_queue[i].card_config, player_number, fight_global_signals)
			yield(board.play_card(card_spawn_point, target_cell, card_to_play), "completed")
			card_queue.pop_at(i)
		else:
			i += 1

func move_cards():
	for column_index in range(board.column_count):
		for row_index in range(board.rows_count):
			var cell = board.get_board_cell(row_index, column_index)
			var card = cell.get_card_or_null()
			if card == null or card.owner_number != player_number:
				continue
			var target_cell = cell.get_relative_board_cell(card.player_attack_direction[player_number], 0)
			var move_cost = card.get_move_cost_or_null(target_cell)
			if move_cost == null:
				continue
			yield(board.move_card(target_cell, card), "completed")



func _on_attack_enter():
	board._on_attack_enter(fight_state, player_number)
	fight_state.next_state()




