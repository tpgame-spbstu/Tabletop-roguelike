extends Spatial

onready var card_inst = load("res://Hand/cart_test.tscn")
onready var hand = load("res://Hand/hand.tscn")
onready var proxy = load("res://Hand/Proxy/proxy.tscn")


func _ready():
	var h = hand.instance()
	add_child(h)

	var c = card_inst.instance()
	var p = proxy.instance()
	p.translate(Vector3(7, 0, -5))
	add_child(p)

	c.translate(Vector3(-7, 0, -5))
	add_child(c)
	# one can replace these with direct func calls
	c.connect("left", h, "add_card")
	c.connect("right", h, "remove_card")

	print(p)
	# p.attach_obj_to(c)
	# p.remove_from(c)

	# var _c = card_inst.instance()
	# _c.translate(Vector3(-7, 0, 5))
	# _c.set_orig_trans(c.get_transform())
	# add_child(_c)
	# _c.connect("doubleclick", p, "attach_obj_to")
	# var h = hand.instance()
	# add_child(h)
	# c.connect("doubleclick", h, "add_card")
	$Camera.make_current()
