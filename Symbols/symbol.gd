extends Reference

class_name Symbol

# Symbol class - simple card symbol class, base class for more complex symbols

var symbol_name

var symbol_texture

var symbol_description

var is_visible

var can_be_transferred

var card

var symbol_name_to_print

func _init(symbol_name, symbol_texture, symbol_description, is_visible,
 can_be_transferred, symbol_name_to_print="default"):
	self.symbol_name = symbol_name
	self.symbol_texture = symbol_texture
	self.symbol_description = symbol_description
	self.is_visible = is_visible
	self.can_be_transferred = can_be_transferred
	self.symbol_name_to_print = symbol_name_to_print

func initialize(card):
	self.card = card

func get_copy():
	return get_script().new(symbol_name, symbol_texture, symbol_description, 
	is_visible, can_be_transferred, symbol_name_to_print)
