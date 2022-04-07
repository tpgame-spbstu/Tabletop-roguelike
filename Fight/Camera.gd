extends Camera

onready var base_rotation := rotation.x
onready var base_translation := translation

func _input(event):
	if event is InputEventMouseMotion:
		translation = base_translation
		rotation.x = base_rotation
		translation.x -= (ease(event.position.x / get_viewport().get_visible_rect().size.x, -0.2) - 0.5) * 3
		rotation.x += (ease(event.position.y / get_viewport().get_visible_rect().size.y, -0.2) - 0.5) / 4
		translation.z -= (ease(event.position.y / get_viewport().get_visible_rect().size.y, -0.2) - 0.5) * 4
