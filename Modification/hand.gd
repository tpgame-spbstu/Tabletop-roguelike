extends Spatial


# stores the cards
var _cards: Array
onready var card_inst = load("res://Modification/card_3d.tscn")
# TODO: substitute, change it with the actual value
const OFFSET := Vector3(0, 0.5, 0)

func _ready():
	var cards = [
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance()
	]
	initialize(cards)
	draw_cards()


func initialize(cards: Array):
	_cards = cards.duplicate()
	# add all the cards as children to the root
	for card in _cards:
		add_child(card)
		card.connect("_mouse_entered", self, "_on_mouse_entered")
		card.connect("_mouse_exited", self, "_on_mouse_exited")


func draw_cards():
	var rad_from := -PI + TAU / 12
	var rad_to := -TAU / 12
	var r = 10
	var pos := Vector3(0, 0, 7)
	var dh = 0.01

	var cur_rad: float
	for i in _cards.size():
		cur_rad = rad_from + i * (rad_to - rad_from) / (_cards.size() - 1)
		_cards[i].translate(pos + Vector3(cos(cur_rad), i * dh, sin(cur_rad)) * r)
		print(_cards[i].get_translation())
		_cards[i].set_orig_pos(_cards[i].get_translation())


func _on_mouse_entered(card):
	var tween = card.get_hower_tween()
	tween.on_enter(OFFSET)


func _on_mouse_exited(card):
	var tween = card.get_hower_tween()
	tween.on_exit()
