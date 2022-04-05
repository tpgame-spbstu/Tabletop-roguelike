extends Reference

var card_name : String
var play_cost : Cost
var symbols : Array = [PackedScene]
var health : int
var power : int

func _init(card_name, play_cost, symbols, health, power):
	self.card_name = card_name
	self.play_cost = play_cost
	self.symbols = symbols
	self.health = health
	self.power = power

