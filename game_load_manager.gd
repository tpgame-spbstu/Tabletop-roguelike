extends Object

class_name GameLoadManager


static func generate_new_game(game_seed = 0) -> GameConfig:
	return GameConfig.new()

static func load_game() -> GameConfig:
	return GameConfig.new()

static func save_game(game_config : GameConfig):
	pass
