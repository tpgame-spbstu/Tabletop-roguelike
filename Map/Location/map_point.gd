extends Area

const SPRITE_SHIFT_VECTOR = Vector3(0, 5, 0)

signal map_point_click(map_point)

var utils = preload("res://Map/utils.gd").new()
onready var _banner = $banner
onready var _sprite_type = $sprite_type
var map_point_config = null
export(Color) var hover_color = Color(0, 1, 0, 1)
export(Color) var highlight_color = Color(1, 1, 1, 1)

export(int) var collision_layer_index = 4


func _ready():
	self.set_collision_layer_bit(collision_layer_index - 1, true)


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
	update_hover()


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
	$AnimationPlayer.stop()
	_sprite_type.hide()


func mark_current():
	_sprite_type.translate(SPRITE_SHIFT_VECTOR)


## make the 'bounding' mesh visible
func highlight():
	$on_hover_mesh.show()
	update_hover()


# legit antonym for highlight
# https://www.synonyms.com/antonyms/highlight
func lowlight():
	$on_hover_mesh.hide()


func is_mouse_hovered():
	var cam = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	return RaycastUtils.is_mouse_hovered_on_area(self, collision_layer_index, cam, get_world(), mouse_pos)


func update_hover(is_hovered = null):
	if is_hovered == null:
		is_hovered = is_mouse_hovered()
	if is_hovered:
		utils.change_mat_color($on_hover_mesh, hover_color)
	else:
		utils.change_mat_color($on_hover_mesh, highlight_color)


func _on_mouse_entered():
	update_hover(true)


func _on_mouse_exited():
	update_hover(false)
