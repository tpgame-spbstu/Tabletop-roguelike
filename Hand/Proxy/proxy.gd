extends Area

signal doubleclick(card)

# original position regarding the animations (= position before the animation)
var _orig_trans: Transform = Transform.IDENTITY setget set_orig_trans, get_orig_trans
var _occupant: Spatial = null
# method every occupant should have, otherwise no collision shape can be built
const SIZE_METH = "get_size"
# tween that is started on hovering
onready var _hover_tween: HoverTween setget , get_hower_tween
onready var _coll_shape: CollisionShape = $CollisionShape

# used in `_get_points`, `_get_points2d` methods
enum {
	ORIG,  # get the original transform (stored in _orig_trans)
	CURR,  # get the current transform
}


func _ready():
	_coll_shape.set_shape(ConvexPolygonShape.new())

	_hover_tween = HoverTween.new()
	add_child(_hover_tween)
	# will use to set the internal state of the tween to NONE
	_hover_tween.connect("tween_all_completed", self, "_on_hover_tween_complete")
	_hover_tween.set_state(_hover_tween.NONE)

	connect("input_event", self, "_on_input_event")


func _on_input_event(_camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.doubleclick:
			print("dblclc")
			emit_signal("doubleclick", self)
		else:  # propogate the event
			if _occupant:
				_occupant.emit_signal("input_event", _camera, event, _pos, _normal, _shape_idx)


func _on_hover_tween_complete():
	_hover_tween.set_state(_hover_tween.NONE)


func get_hower_tween() -> HoverTween:
	return _hover_tween


func _add_collision_shape(points: PoolVector3Array):
	(_coll_shape.get_shape() as ConvexPolygonShape).set_points(points)


func _offset_points_y(points: PoolVector3Array, coeff: float, offset=null) -> PoolVector3Array:
	assert(_occupant != null)
	if not offset:
		offset = _occupant.call(SIZE_METH).y
	for i in points.size():
		points[i].y += coeff * offset
	return points


func _make_high(points: PoolVector3Array) -> PoolVector3Array:
	return _offset_points_y(points, 1.0)


func _make_low(points: PoolVector3Array) -> PoolVector3Array:
	return _offset_points_y(points, -1.0)


func _get_cshape_points(trans=ORIG) -> PoolVector3Array:
	var points := _get_points(trans)
	# the docs say it's passed by value, no need to copy
	return _make_high(points) + _make_low(points)


func _get_union_cshape_points() -> PoolVector3Array:
	return _make_high(_get_points(CURR)) + _make_low(_get_points(ORIG))


func _attach(obj) -> bool:
	if _occupant or not obj.has_method(SIZE_METH):
		return false
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	add_child(obj)
	_occupant = obj
	# set the coliision shape's shape
	_add_collision_shape(_get_cshape_points())
	return true


## attach obj to self, move self to obj's transform
func attach_to_obj(obj: Spatial):
	print("yoyo")
	var trans = obj.global_transform
	if _attach(obj):
		global_transform = trans
		obj.global_transform = trans


## attach obj to self, move obj to self transform
func attach_obj_to(obj: Spatial):
	var trans = global_transform
	if _attach(obj):
		obj.global_transform = trans


## remove obj from self
func remove_from(obj: Spatial, adoption_parent):
	var trans = global_transform
	if obj == _occupant:
		remove_child(obj)
		# add `obj` to the grandparent, hopefully
		adoption_parent.add_child(obj)
		obj.global_transform = trans
		_occupant = null


func get_size() -> Vector3:
	if _occupant:
		return _occupant.call(SIZE_METH)
	return Vector3.ZERO


func set_orig_trans(trans):
	_orig_trans = trans


func get_orig_trans() -> Transform:
	return _orig_trans


func get_orig_rot_y() -> float:
	return get_orig_trans().basis.get_euler().y


func _get_points(trans=ORIG) -> PoolVector3Array:
	var pos
	var ext_rot
	match trans:
		ORIG:
			pos = get_orig_trans().origin
			ext_rot = get_orig_rot_y()
		CURR:
			pos = get_global_transform().origin
			# no need to call `.angle_to` since it is the angle itself
			# `.y` is the rotation on the Y-axis
			ext_rot = get_global_transform().basis.get_euler().y
		_:
			return [] as PoolVector3Array
	var _size: Vector3 = _occupant.call(SIZE_METH) / 2
	# if not 0, both the length and the angle are incorrect, as
	# both of them are needed in plane, not in space
	_size = Vector3(_size.x, 0, _size.z)
	var length := _size.length()
	var phi := _size.angle_to(Vector3.RIGHT)
	var points := PoolVector3Array()

	# get the 4 points of the card's rectangle
	# counter clockwise / \ / \ (up, up, down, down)
	for psi in [phi + ext_rot, -phi + ext_rot + PI, phi + ext_rot + PI, -phi + ext_rot]:
		points.push_back(pos + Vector3.RIGHT.rotated(Vector3.UP, psi) * length)
	return points


func _get_2dpoints(trans=ORIG) -> PoolVector2Array:
	var points: PoolVector2Array = []
	for point in _get_points(trans):
		points.push_back(Vector2(point.x, point.z))
	return points


func get_intersection_with(other) -> Array:
	assert(other.has_method("_get_2dpoints"))
	return Geometry.intersect_polygons_2d(_get_2dpoints(), other._get_2dpoints())


func get_union_with(other) -> Array:
	assert(other.has_method("_get_2dpoints"))
	return Geometry.merge_polygons_2d(_get_2dpoints(), other._get_2dpoints())
