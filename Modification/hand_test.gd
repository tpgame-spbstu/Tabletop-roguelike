extends Spatial

onready var card_inst = load("res://Modification/card_3d.tscn")
onready var hand = load("res://Modification/hand.tscn")

func _ready():
	var c = card_inst.instance()
	c.translate(Vector3(-7, 0, -5))
	c.set_orig_trans(c.get_transform())
	add_child(c)
	var h = hand.instance()
	add_child(h)
	c.connect("doubleclick", h, "add_card")
	$Camera.make_current()
