extends Object

class_name GameLoadManager


static func get_temp_map_config():
	var MapConfig = preload("res://map_config.gd")
	var MapLocation = preload("res://map_location.gd")
	var loc4 = MapLocation.new("res://Fight/fight_location.tscn", {"shuffle_seed": 5}, [], -1, 3)
	var loc3 = MapLocation.new("res://Fight/fight_location.tscn", {"shuffle_seed": 1}, [loc4], 1, 2)
	var loc2 = MapLocation.new("res://Fight/fight_location.tscn", {"shuffle_seed": 1337}, [loc3], 1, 1)
	var loc1 = MapLocation.new("", {}, [loc2], 0, 0)
	var temp_map_config = MapConfig.new()
	temp_map_config.map_location_grapth = loc1
	temp_map_config.current_map_location = loc1
	return temp_map_config


static func get_temp_deck_config():
	var DeckConfig = preload("res://deck_config.gd")
	var CardConfig := load("res://Card/card_config.gd")
	var deck_config = DeckConfig.new()
	deck_config.cards.append(CardConfig.new(
		"Карта 1", Cost.new(1, 0, 0), [], 3, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта 2", Cost.new(1, 0, 0), [], 3, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта 3", Cost.new(1, 0, 0), [], 3, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта 4", Cost.new(1, 0, 0), [], 3, 2
		))
	return deck_config


static func get_temp_inventory_config():
	var InventoryConfig = preload("res://inventory_config.gd")
	var inventory_config = InventoryConfig.new()
	return inventory_config


static func get_temp_game_config():
	var game_config = preload("res://game_config.gd").new()
	game_config.map_config = get_temp_map_config()
	game_config.deck_config = get_temp_deck_config()
	game_config.inventory_config = get_temp_inventory_config()
	return game_config


static func generate_new_game(game_seed = 0):
	return get_temp_game_config()


static func load_game():
	return get_temp_game_config()


static func save_game(game_config):
	pass
