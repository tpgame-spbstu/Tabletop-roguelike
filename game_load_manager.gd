extends Object

class_name GameLoadManager


static func generate_new_game(game_seed = 0):
	return preload("res://game_config.gd").new()

static func load_game():
	return preload("res://game_config.gd").new()

static func save_game(game_config):
	pass
