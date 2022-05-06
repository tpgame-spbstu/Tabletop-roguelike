extends Area


signal map_point_click(map_point)

var utils = preload("res://Map/utils.gd").new()
onready var _banner = $banner
onready var _sprite_type = $sprite_type
var map_point_config = null
export(Color) var hover_color = Color(0, 1, 0, 1)
export(Color) var highlight_color = Color(1, 1, 1, 1)

func initialize(map, map_point_config):
	self.map_point_config = map_point_config
  
	connect("map_point_click", map, "_on_map_point_click")
	# connecting the hovering signals
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	_set_sprite_type(map_point_config.type)
	_set_textures(map_point_config.get_textures())


func _process(delta):
	if not map_point_config._is_visited:
		_sprite_type.rotate_y(delta * PI)


func get_size():
	return (get_node("CollisionShape").shape as BoxShape).get_extents() * 2


func get_mesh() -> MeshInstance:
	return get_node("MeshInstance") as MeshInstance


func _set_textures(textures: Array):
	utils.change_textures(get_mesh(), textures)


func _set_sprite_type(type):
	var img_texture
	if type == map_point_config.types_map.FIGHT:
		img_texture  = load("res://Map/Sprites/sword.png")
	elif type == map_point_config.types_map.MOD:
		img_texture  = load("res://Map/Sprites/book.png")
	else:
		img_texture  = load("res://Map/Sprites/default.png")
	_sprite_type.texture = img_texture


func _on_Point_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_mask() == BUTTON_LEFT:
			emit_signal("map_point_click", self)


## writes to map_point_config the `_is_visited` flag
## raises the flag
##
## :animate: whether to animate the flag raising or just to make them shown
func mark_visited(animate: bool=true):
	map_point_config.set_visited(true)
	_banner.set_sail(animate)
	_sprite_type.queue_free()


## make the 'bounding' mesh visible
##
## @warn: truth be told, not sure what `use_shadow_to_opacity`
##        exactly does, but in allows to completely hide or
##        show the mesh, hence is used here
func highlight():
	var mat = utils.get_mat($on_hover_mesh)
	mat.flags_use_shadow_to_opacity = false
	utils.set_mat($on_hover_mesh, mat)


# legit antonym for highlight
# https://www.synonyms.com/antonyms/highlight
func lowlight():
	var mat = utils.get_mat($on_hover_mesh)
	mat.flags_use_shadow_to_opacity = true
	utils.set_mat($on_hover_mesh, mat)


func _on_mouse_entered():
	utils.change_mat_color($on_hover_mesh, hover_color)


func _on_mouse_exited():
	utils.change_mat_color($on_hover_mesh, highlight_color)
