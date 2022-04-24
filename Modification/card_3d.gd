extends StaticBody

# signal _mouse_entered(card)
# signal _mouse_exited(card)

# original position regarding the animations (= position before the animation)
var _orig_pos: Vector3 setget set_orig_pos, get_orig_pos
# tween that is started on hovering
onready var _hover_tween: HoverTween setget , get_hower_tween


func _ready():
	_hover_tween = HoverTween.new()
	add_child(_hover_tween)
	# will use to set the internal state of the tween to NONE
	_hover_tween.connect("tween_all_completed", self, "_on_hover_tween_complete")
	_hover_tween.set_state(_hover_tween.NONE)

	# connect("mouse_entered", self, "_on_mouse_entered")
	# connect("mouse_exited", self, "_on_mouse_exited")

# func _on_mouse_entered():
#     print("Mouse!")
#     emit_signal("_mouse_entered", self)


# func _on_mouse_exited():
#     emit_signal("_mouse_exited", self)


func _on_hover_tween_complete():
	_hover_tween.set_state(_hover_tween.NONE)


func get_hower_tween():
	return _hover_tween


func set_orig_pos(pos):
	_orig_pos = pos
	# print("orig: ", _orig_pos)


func _get_points() -> PoolVector3Array:
	# print("local rot: ", rotation)
	# print("local trans: ", transform.basis.get_euler())
	var pos := get_translation()
	var _size: Vector3 = $CollisionShape.shape.get_extents() * 2
	# print("rotation: ", get_rotation())
	var phi = _size.angle_to(Vector3.RIGHT)# + get_rotation().y# + get_rotation().signed_angle_to(Vector3.RIGHT, Vector3.UP)
	# var phi = get_rotation().signed_angle_to(Vector3.RIGHT, Vector3.UP)
	# print("phi: ", rad2deg(_size.angle_to(Vector3.RIGHT)))
	var ext_rot = get_rotation().y
	# var ext_rot = global_transform.basis.get_euler().angle_to(Vector3.RIGHT)
	# print("ext rot deg: ", rad2deg(ext_rot))
	# print("phi: ", rad2deg(phi))
	# print("sum: ", Vector3.RIGHT.rotated(Vector3.UP, phi + ext_rot), " rot: ", Vector3.RIGHT.rotated(Vector3.UP, phi).rotated(Vector3.UP, ext_rot))
	var length := _size.length() / 2
	var points: PoolVector3Array

	# get the 4 points of the card's rectangle
	# clockwise
	for psi in [phi + ext_rot, -phi + ext_rot + PI, phi + ext_rot + PI, -phi + ext_rot]:
		# print("psi: ", rad2deg(psi))
		points.push_back(pos + Vector3.RIGHT.rotated(Vector3.UP, psi) * length)
	return points


func _get_2dpoints() -> PoolVector2Array:
	var points: PoolVector2Array
	for point in _get_points():
		points.push_back(Vector2(point.x, point.z))
	return points


func get_orig_pos():
	return _orig_pos
