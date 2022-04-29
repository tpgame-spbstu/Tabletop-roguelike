extends Area

var map_point_config = null

signal map_point_click(map_point)

func initialize(map, map_point_config):
	self.map_point_config = map_point_config
	connect("map_point_click", map, "_on_map_point_click")
	# connecting the hovering signals
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	_set_textures(map_point_config.get_textures())


func _set_textures(textures: Array):
	var mesh = get_node("MeshInstance")
	# number of textures should be the >= than the number of surfaces
	# if more, the excess ones will be ignored
	if textures.size() >= mesh.get_surface_material_count():
		for i in mesh.get_surface_material_count():
			# if not duplicated, all other instances will share the same material
			var mat = mesh.get_active_material(i).duplicate()
			# iirc, texture is mixed with the color
			# the white color shouldn't mess the texture img up
			mat.set_albedo(Color(1, 1, 1, 1))
			mat.set_texture(SpatialMaterial.TEXTURE_ALBEDO, load(textures[i]))
			# it seems, get_active_material returns a copy, hence the need in reassignment
			mesh.set_surface_material(i, mat)


func _on_Point_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_mask() == BUTTON_LEFT:
			emit_signal("map_point_click", self)


func _on_mouse_entered():
	$on_hover_mesh.show()


func _on_mouse_exited():
	$on_hover_mesh.hide()
