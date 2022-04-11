extends Reference

class_name Symbol

var symbol_name

var symbol_texture

var symbol_description

var is_visible

var can_be_transferred

var card

func _init(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred):
	self.symbol_name = symbol_name
	self.symbol_texture = symbol_texture
	self.symbol_description = symbol_description
	self.is_visible = is_visible
	self.can_be_transferred = can_be_transferred

func initialize(card):
	self.card = card

func get_copy():
	return get_script().new(symbol_name, symbol_texture, symbol_description, is_visible, can_be_transferred)
