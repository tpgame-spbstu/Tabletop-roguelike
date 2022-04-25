extends StaticBody

signal doubleclick(card)

# original position regarding the animations (= position before the animation)
var _orig_trans: Transform setget set_orig_trans, get_orig_trans
# tween that is started on hovering
onready var _hover_tween: HoverTween setget , get_hower_tween


func _ready():
	_hover_tween = HoverTween.new()
	add_child(_hover_tween)
	# will use to set the internal state of the tween to NONE
	_hover_tween.connect("tween_all_completed", self, "_on_hover_tween_complete")
	_hover_tween.set_state(_hover_tween.NONE)

	connect("input_event", self, "_on_input_event")


func _on_input_event(camera, event, pos, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("doubleclick", self)


func _on_hover_tween_complete():
	_hover_tween.set_state(_hover_tween.NONE)


func get_hower_tween():
	return _hover_tween


func get_size():
	# mesh should be of CubeMesh type
	return get_node("MeshInstance").mesh.get_size()


func set_orig_trans(trans):
	_orig_trans = trans


func get_orig_trans():
	return _orig_trans


func get_orig_rot_y():
	return get_orig_trans().basis.get_euler().y


func _get_points() -> PoolVector3Array:
	var pos = get_orig_trans().origin
	var _size: Vector3 = $CollisionShape.shape.get_extents()
	var phi := _size.angle_to(Vector3.RIGHT)
	# no need to call `.angle_to` since it is the angle itself
	# `.y` is the rotation on the Y-axis
	var ext_rot = get_orig_rot_y()
	var length := _size.length()
	var points: PoolVector3Array = []

	# get the 4 points of the card's rectangle
	# counter clockwise / \ / \ (up, up, down, down)
	for psi in [phi + ext_rot, -phi + ext_rot + PI, phi + ext_rot + PI, -phi + ext_rot]:
		points.push_back(pos + Vector3.RIGHT.rotated(Vector3.UP, psi) * length)
	return points


func _get_2dpoints() -> PoolVector2Array:
	var points: PoolVector2Array = []
	for point in _get_points():
		points.push_back(Vector2(point.x, point.z))
	return points
