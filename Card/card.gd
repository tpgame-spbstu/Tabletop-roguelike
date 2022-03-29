extends Spatial

enum {DECK, HAND, BOARD}

var CardConfig = preload("res://Card/card_config.gd")
var player
var src
var card_name
var cost
var symbols = []
var health
var power
var attack_range
var attack_type
var move_cost
var animation = null

onready var card_visuals_2d = $card_visuals/Viewport/card_visuals_2d


signal animation_ended()

func _process(delta):
	if animation != null:
		if animation.process(delta):
			animation = null
			emit_signal("animation_ended")

func initialize(card_config, player):
	self.player = player
	src = card_config
	card_name = card_config.card_name
	cost = card_config.cost
	symbols = card_config.symbols
	health = card_config.health
	power = card_config.power
	attack_range = card_config.attack_range
	attack_type = card_config.attack_type
	move_cost = card_config.move_cost
	card_visuals_2d.update_to_card(self)
