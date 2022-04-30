extends Area


signal map_point_click(map_point)

var utils = preload("res://Map/utils.gd").new()
var map_point_config = null

func initialize(map, map_point_config):
	self.map_point_config = map_point_config
	connect("map_point_click", map, "_on_map_point_click")
	# connecting the hovering signals
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	_set_textures(map_point_config.get_textures())


func get_mesh() -> MeshInstance:
	return get_node("MeshInstance") as MeshInstance


func _set_textures(textures: Array):
	utils.change_textures(get_mesh(), textures)


func _on_Point_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_mask() == BUTTON_LEFT:
			emit_signal("map_point_click", self)


func _on_mouse_entered():
	$on_hover_mesh.show()


func _on_mouse_exited():
	$on_hover_mesh.hide()
