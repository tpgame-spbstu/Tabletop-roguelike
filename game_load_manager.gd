extends Object

class_name GameLoadManager


static func get_temp_map_config():
	var MapConfig = preload("res://Map/map_config.gd")
	var MapLocation = preload("res://Map/Location/map_location.gd")

	var fight_scene : String = "res://Fight/fight_location.tscn"
	var loc5 = MapLocation.new(fight_scene, {}, Vector2(-1, 1))
	var loc4 = MapLocation.new(fight_scene, {}, Vector2(-1, 3))
	var loc3 = MapLocation.new(fight_scene, {}, Vector2(1, 2))
	var loc2 = MapLocation.new(fight_scene, {}, Vector2(1, 1))
	var loc1 = MapLocation.new("", {}, Vector2(0, 0))

	# creating the graph `vertex`: [`available_vertexes`]
	var locaton_map = {
		loc5: [loc3],
		loc4: [],
		loc3: [loc4],
		loc2: [loc3],
		loc1: [loc2, loc5],
	}

	var temp_map_config = MapConfig.new()
	temp_map_config.map_location_graph = locaton_map
	temp_map_config.current_map_location = loc1

	return temp_map_config


static func get_temp_deck_config():
	var DeckConfig = preload("res://deck_config.gd")
	var CardConfig := preload("res://Card/card_config.gd")
	var deck_config = DeckConfig.new()
	deck_config.cards.append(CardConfig.new(
		"Карта 1", "цена", [], 3, 2, 1, "range", 1
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
