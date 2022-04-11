extends Node2D

export(Vector2) var card_scale := Vector2(.4, .4)
# constants don't work when importing, somehow
#               -TAU                TAU                 TAU / 360
export(float, -6.283185307179586, 6.283185307179586, 0.017453292519943295) var rad_from := -TAU * 3 / 8
export(float, -6.283185307179586, 6.283185307179586, 0.017453292519943295) var rad_to := -TAU / 8
export(float) var r_cos := 200
export(float) var r_sin := 200

var cards: Array
onready var card = load("res://Modification/card_2d.tscn")


func _ready():
	var _card
	var nb_points = 10
	var delta = (rad_to - rad_from) / nb_points
	var size = get_viewport().get_size()
	var center = Vector2(size.x / 2, size.y + sin(abs(rad_from)) * r_sin)

	for i in range(nb_points + 1):
		var phi = rad_from + i * delta

		_card = card.instance()
		add_child(_card)
		_card.set_scale(card_scale)
		_card.set_position(center + Vector2(cos(phi) * r_cos, sin(phi) * r_sin) - Vector2(0, _card.get_size().length() / 2))
		# TAU / 4 = 90. Since the angles are counted from RIGHT (1, 0),
		# +90 is needed to bring the top from left to up
		_card.set_rotation(phi + TAU / 4)

		# connect the card's signals to handle them here
		_card.connect("_mouse_entered", self, "_on_mouse_enter")
		_card.connect("_mouse_exited", self, "_on_mouse_exit")


"""
	FIXME: for some reason the cards are changed faster when moving through them from left to right
"""
func _on_mouse_enter(card):
	# display the hovered card on top of others
	card.set_z_index(1)


func _on_mouse_exit(card):
	# the cards are dr_coswn in their order in the scene tree, hence
	# setting the z_index to 0 doesn't breaks the cards' order
	card.set_z_index(0)
