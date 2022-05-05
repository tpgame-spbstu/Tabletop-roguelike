extends Object

class_name GameLoadManager

# GameLoadManager class - save/load manager for GameConfig

static func get_temp_map_config():
	var MapConfig = preload("res://Map/map_config.gd")
	var MapPointConfig = preload("res://Map/Location/map_point_config.gd")
	
	var card_queue1 = []
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 0))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 3))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Гоблин-лучник"), 3, 2))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Гоблин-лучник"), 5, 2))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Гоблин-лучник"), 6, 1))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Банши"), 7, 0))
	card_queue1.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жрец тьмы"), 7, 3))
	
	var card_queue2 = []
	card_queue2.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 0))
	card_queue2.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 2))
	card_queue2.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 2, 1))
	card_queue2.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 2, 3))
	
	var card_queue3 = []
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 0))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 1, 2))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 2, 3))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Мумия"), 3, 1))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 3, 0))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Мандрагора"), 5, 2))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 6, 1))
	card_queue3.append(CardQueueItem.new(BaseCardsManager.get_card_config_copy("Жук"), 6, 3))

	var fight_scene : String = "res://Fight/fight_location.tscn"
	var sacrifice_scene : String = "res://Sacrifice_location/sacrifice_location.tscn"
	var loc5 = MapPointConfig.new(fight_scene, {"shuffle_seed": 5, "ai_card_queue": card_queue2}, Vector2(-1, 1))
	var loc4 = MapPointConfig.new(fight_scene, {"shuffle_seed": 1, "ai_card_queue": card_queue3}, Vector2(-1, 3))
	var loc3 = MapPointConfig.new(fight_scene, {"shuffle_seed": 1337, "ai_card_queue": card_queue1}, Vector2(1, 2))
	var loc2 = MapPointConfig.new(sacrifice_scene, {}, Vector2(1, 1), false,
		["res://Map/Location/point_textures/texture_cheese_albedo.png"])
	var loc1 = MapPointConfig.new(fight_scene, {"shuffle_seed": 10, "ai_card_queue": card_queue2}, Vector2(0, 0))
	var loc0 = MapPointConfig.new("", {}, Vector2(0, -1), true)

	# creating the graph `vertex`: [`available_vertexes`]
	var point_map = {
		loc5: [loc3],
		loc4: [],
		loc3: [loc4],
		loc2: [loc3],
		loc1: [loc2, loc5],
		loc0: [loc1],
	}

	var temp_map_config = MapConfig.new()
	temp_map_config.map_point_graph = point_map
	temp_map_config.current_map_point_config = loc0

	return temp_map_config


static func get_temp_deck_config():
	var DeckConfig = preload("res://deck_config.gd")
	var CardConfig := load("res://Card/card_config.gd")
	var deck_config = DeckConfig.new()
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук медленный"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук быстрый"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук средний"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук средний"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук средний"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук ослабляющий"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук ослабляющий"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук контратаки"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук дальнобойный"))
	deck_config.cards.append(BaseCardsManager.get_card_config_copy("Жук дальнобойный"))
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
	return null


static func save_game(game_config):
	pass
