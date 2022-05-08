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
	connect("mouse_entered", map, "_on_map_point_mouse_entered", [self])
	connect("mouse_exited", map, "_on_map_point_mouse_exited", [self])

	if map_point_config.is_visited():
		mark_visited(false)
	_set_sprite_type(map_point_config.type)
	$AnimationPlayer.play("sprite_animation")


func get_size():
	return (get_node("CollisionShape").shape as BoxShape).get_extents() * 2


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
	$AnimationPlayer.stop()


## make the 'bounding' mesh visible
func highlight():
	$on_hover_mesh.show()


# legit antonym for highlight
# https://www.synonyms.com/antonyms/highlight
func lowlight():
	$on_hover_mesh.hide()


func _on_mouse_entered():
	utils.change_mat_color($on_hover_mesh, hover_color)


func _on_mouse_exited():
	utils.change_mat_color($on_hover_mesh, highlight_color)
