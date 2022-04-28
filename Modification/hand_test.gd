extends Spatial

onready var card_inst = load("res://cart_test.tscn")
onready var hand = load("res://Modification/hand.tscn")


func _ready():
	var h = hand.instance()
	add_child(h)

	var c = card_inst.instance()
	c.translate(Vector3(-7, 0, -5))
	add_child(c)
	# one can replace these with direct func calls
	c.connect("left", h, "add_card")
	c.connect("right", h, "remove_card")

	$Camera.make_current()
