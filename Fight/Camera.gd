extends Camera

onready var base_rotation := rotation.x
onready var base_translation := translation

func _input(event):
	if event is InputEventMouseMotion:
		translation = base_translation
		rotation.x = base_rotation
		translation.x -= (event.position.x / get_viewport().get_visible_rect().size.x - 0.5) * 2
		rotation.x -= (event.position.y / get_viewport().get_visible_rect().size.y - 0.5) / 4
		translation.z -= (event.position.y / get_viewport().get_visible_rect().size.y - 0.5) * 2
	
