extends Node

# FightGlobalSignals node - centralized fight location signal system

signal card_played(board_cell, card)
signal card_is_dead(board_cell, card)
signal card_moved(prev_board_cell, cur_board_cell, card)
