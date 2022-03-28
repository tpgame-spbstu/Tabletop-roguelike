extends Spatial

signal return_to_map()

func initialize(map, deck_config, inventory_config, params : Dictionary):
	connect("return_to_map", map, "_on_location_return_to_map")
	
func _on_Button_pressed():
	emit_signal("return_to_map")
	queue_free()
