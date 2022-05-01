extends Area


signal map_point_click(map_point)

var utils = preload("res://Map/utils.gd").new()
onready var _banner = $banner
var map_point_config = null


func initialize(map, map_point_config):
	self.map_point_config = map_point_config
	_set_textures(map_point_config.get_textures())

	connect("map_point_click", map, "_on_map_point_click")


func get_size():
	return (get_node("CollisionShape").shape as BoxShape).get_extents() * 2


func get_mesh() -> MeshInstance:
	return get_node("MeshInstance") as MeshInstance


func _set_textures(textures: Array):
	utils.change_textures(get_mesh(), textures)


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
