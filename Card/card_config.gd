extends Reference

var card_name : String
var cost
var symbols
var health
var power
var attack_range
var attack_type
var move_cost

func _init(card_name, cost, symbols, health, power, attack_range, attack_type, move_cost):
	self.card_name = card_name
	self.cost = cost
	self.symbols = symbols
	self.health = health
	self.power = power
	self.attack_range = attack_range
	self.attack_type = attack_type
	self.move_cost = move_cost



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
