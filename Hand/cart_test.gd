extends Spatial


signal left(cart)
signal right(cart)

func get_size():
	return (($MeshInstance as MeshInstance).mesh as CubeMesh).get_size()

func _ready():
	connect("input_event", self, "_on_input_event")


func _on_input_event(_cam, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == BUTTON_LEFT:
			# print("left ", self)
			emit_signal("left", self)
		elif event.get_button_index() == BUTTON_RIGHT:
			# print("right ", self)
			emit_signal("right", self)
