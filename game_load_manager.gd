extends Object

class_name GameLoadManager


class CardQueueItem:
	var card_config
	var loop_number
	var column_index
	func _init(card_config, loop_number, column_index):
		self.card_config = card_config
		self.loop_number = loop_number
		self.column_index = column_index

static func get_temp_map_config():
	var MapConfig = preload("res://Map/map_config.gd")
	var MapLocation = preload("res://Map/Location/map_location.gd")
	var CardConfig := load("res://Card/card_config.gd")
	
	var card_queue1 = []
	card_queue1.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 0))
	card_queue1.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 1))
	card_queue1.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 2))
	card_queue1.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 3))
	
	var card_queue2 = []
	card_queue2.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 0))
	card_queue2.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 2))
	card_queue2.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 2, 1))
	card_queue2.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 2, 3))
	
	var card_queue3 = []
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 0))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 1, 2))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 2, 3))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 2, 1))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 3, 0))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 3, 2))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 4, 1))
	card_queue3.append(CardQueueItem.new(CardConfig.new("Враг обычный", null, [], [], [], 1, 1), 4, 3))

	var fight_scene : String = "res://Fight/fight_location.tscn"
	var sacrifice_scene : String = "res://Sacrifice_location/sacrifice_location.tscn"
	var loc5 = MapLocation.new(fight_scene, {"shuffle_seed": 5, "ai_card_queue": card_queue2}, Vector2(-1, 1))
	var loc4 = MapLocation.new(fight_scene, {"shuffle_seed": 1, "ai_card_queue": card_queue3}, Vector2(-1, 3))
	var loc3 = MapLocation.new(fight_scene, {"shuffle_seed": 1337, "ai_card_queue": card_queue2}, Vector2(1, 2),
		["res://Map/Location/point_textures/texture_cheese_albedo.png", "res://Map/Location/point_textures/texture_cheese_albedo.png"])
	var loc2 = MapLocation.new(sacrifice_scene, {}, Vector2(1, 1))
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
	var CardConfig := load("res://Card/card_config.gd")
	var deck_config = DeckConfig.new()
	deck_config.cards.append(CardConfig.new(
		"Карта быстрая", Cost.new(3, 0, 0), [SymbolManager.get_symbol("fast")], [], [], 1, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта медленная", Cost.new(2, 0, 0), [SymbolManager.get_symbol("slow")], [], [], 3, 3
		))
	deck_config.cards.append(CardConfig.new(
		"Карта обычная", Cost.new(1, 0, 0), [], [], [], 2, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта ослабляющая", Cost.new(2, 0, 0), [SymbolManager.get_symbol("weakening")], [], [], 1, 2
		))
	deck_config.cards.append(CardConfig.new(
		"Карта котратаки", Cost.new(3, 0, 0), [SymbolManager.get_symbol("counterattack")], [], [], 1, 3
		))
	deck_config.cards.append(CardConfig.new(
		"Карта дальнобойная", Cost.new(3, 0, 0), [SymbolManager.get_symbol("range")], [], [], 2, 1
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
