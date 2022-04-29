extends Reference


func set_mat(mesh, mat, ind=0):
	mesh.set_surface_material(ind, mat)


func get_mat(mesh, ind=0):
	return mesh.get_active_material(ind).duplicate()


func change_texture(mesh, texture, ind=0, albedo_color=null):
	# if not duplicated, all other instances will share the same material
	var mat = get_mat(mesh, ind)
	# iirc, texture is mixed with the color
	# the white color shouldn't mess the texture img up
	mat.set_albedo(Color(1, 1, 1, 1) if not albedo_color else albedo_color)
	mat.set_texture(SpatialMaterial.TEXTURE_ALBEDO, load(texture))
	# it seems, get_active_material returns a copy, hence the need in reassignment
	mesh.set_surface_material(ind, mat)


func change_textures(mesh, textures, albedo_colors=null):
	var surf_mat_num = mesh.get_surface_material_count()
	# number of textures should be the >= than the number of surfaces
	# if more, the excess ones will be ignored
	if textures.size() >= surf_mat_num:
		for i in surf_mat_num:
			change_texture(mesh, textures[i], i, albedo_colors[i] if albedo_colors and i < albedo_colors.size() else null)


func change_mat_color(mesh, new_color):
	var mat = get_mat(mesh)
	mat.set_albedo(new_color)
	set_mat(mesh, mat)
