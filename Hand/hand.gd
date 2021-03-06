extends Spatial


signal mouse_entered(card)
signal mouse_exited(card)
signal hand_left_click(proxy, card)
signal hand_right_click(proxy, card)

# stores the cards
var _cards: Array
# stores currently hovered proxy
var _hovered
# set for every proxy, ray is also checking only this layer
# done to avoid ray picking proxy, that are not in the hand
var _collision_layer_bit: int = 2
onready var _proxy = preload("res://Hand/Proxy/proxy.tscn")
var _proxies: Array = []
onready var card_inst = preload("res://Hand/cart_test.tscn")
onready var utils = preload("res://Hand/utils.gd").new()
# TODO: substitute, change it with the actual value
const OFFSET := Vector3(0, 0.1, 0.1)

onready var highlighter:= get_parent().get_node("hand_hightlight")


# for running as a standalone scene
# one can safely remove the whole method
func _ready():
	initialize()


func initialize(cards: Array=[]):
	add_cards(cards)
	# the card is passed, so connect only oneself
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")


func _notification(what):
	match what:
		# if the card was hovered, it remains in hovered state
		# when the window is minimized, mouse position is not updated
		# so clean up the hovered
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if _hovered:
				emit_signal("mouse_exited", _hovered)


## checks whether the hovered proxy and the current mouse position are on the different
## sides of the line
##
## @desc: in order to make the transition from hovered proxy to the one under it, an intersecting
##        polygon is created. It is split in two halves (almost) using `least square regression`.
##        if the hovered proxy is on one side of the regression line while the mouse position is on the other,
##        then one needs to make the proxy, on which the mouse is on, hovered,
##        and the one hovered at the moment unhovered
##
## :line_coeffs: coeffs of the line
## :proxy_pos: position of the hovered card
## :mouse_pos: position of the mouse
##
## :return: true, if on the opposite sides of the line, false otherwise
func _is_hovering_new_proxy(line_coeffs: Vector2, proxy_pos: Vector2, mouse_pos: Vector2):
	return utils.get_line_sign(line_coeffs, proxy_pos) * utils.get_line_sign(line_coeffs, mouse_pos) < 0


## actions taken on mouse hovering the cards
##
## @desc: handles mouse hovers.
##        several cases:
##           no hovered card (1)
##           one card:
##              becomes hovered (2)
##              becomes unhovered (3)
##           two cards:
##              intersection, in hovered part (4)
##              intersection, in new card part (5)
##              transition from hovered to new bypassing their intersection (6)
##
##        (1): do nothing
##        (2): emit mouse enter
##        (3): emit mouse exit
##        (4): do nothing
##        (5): emit mouse exit for the hovered card, emit mouse enter for the new card
##        (6): emit mouse exit for the hovered card, emit mouse enter for the new card
##
## :event: event, not used
## :return: void

# TODO make the tween change the collision shape so that there are no holes
# union
func _mouse_hovering(_event):
	# set-up for intersecting cards under the mouse
	var cam = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = cam.project_ray_origin(mouse_pos)
	# value is big enough to get any intersection
	# though the cards are in between [0, 2] on Y-axis
	var RAY_LENGTH = 1000
	var ray_to = ray_from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state

	# get the closest (highest on Y-axis) proxy under the mouse
	# godot doesn't support named function arguments, hence the comments
	var first_proxy = space_state.intersect_ray(
		ray_from,  # from
		ray_to,  # to
		[],  # exclude
		_get_collision_layer(),  # collision layer of the ray
		false,  # collide with bodies
		true  # collide with areas (proxy is an area)
	)
	if first_proxy:
		first_proxy = first_proxy["collider"]
		# case (2)
		# if not taking into account the tween, recursion between cases 2 and 3
		if not _hovered:
			if not first_proxy.get_hower_tween().is_active() or Geometry.is_point_in_polygon(Vector2(ray_to.x, ray_to.z), first_proxy._get_2dpoints()):
				emit_signal("mouse_entered", first_proxy)
		else:
			# case (6)
			if first_proxy != _hovered:
				emit_signal("mouse_exited", _hovered)
				emit_signal("mouse_entered", first_proxy)
				return
			# get the proxy under the first proxy, if any
			# [_hovered] means to ignore the hovered proxy during the ray casting
			var second_proxy = space_state.intersect_ray(
				ray_from,  # from
				ray_to,  # to
				[_hovered],  # excluded
				_get_collision_layer(),  # collision layer of the ray
				false,  # collide with bodies
				true  # collides with areas
			)
			if second_proxy:
				second_proxy = second_proxy["collider"]
				# get the polygons of the proxies (array of their vertexes)
				var poly1 = first_proxy._get_2dpoints()
				var poly2 = second_proxy._get_2dpoints()
				var inter = Geometry.intersect_polygons_2d(poly1, poly2)
				# check whether the two proxies intersect
				if inter:
					# get the center-line of the intersection area
					var line_coeffs = utils.least_squares_regression(inter[0])
					var first_proxy_trans = first_proxy.get_translation()
					var mouse_local_pos = cam.project_position(mouse_pos, first_proxy_trans.y)
					mouse_local_pos = Vector2(mouse_local_pos.x, mouse_local_pos.z)
					var first_proxy_pos = Vector2(first_proxy_trans.x, first_proxy_trans.z)

					# check whether the hovered proxy and the mouse are on different sides of the line
					if _is_hovering_new_proxy(line_coeffs, first_proxy_pos, mouse_local_pos):
						# case (5)
						emit_signal("mouse_exited", first_proxy)
						emit_signal("mouse_entered", second_proxy)
	# case (3)
	elif _hovered and not first_proxy:
		emit_signal("mouse_exited", _hovered)


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_hovering(event)


func _on_mouse_entered(proxy):
	_hovered = proxy
	var tween = proxy.get_hower_tween()
	tween.on_enter(OFFSET)


func _on_mouse_exited(proxy):
	_hovered = null
	var tween = proxy.get_hower_tween()
	tween.on_exit()


func _get_collision_layer():
	return 1 << _collision_layer_bit


func _add_card(card):
	if card in _cards:
		return
	var proxy = _proxy.instance()
	add_child(proxy)

	proxy.attach_obj_to(card)
	proxy.connect("_input_event", self, "_on_hand_cell_input_event")

	proxy.set_collision_layer_bit(_collision_layer_bit, true)
	_cards.push_back(card)
	_proxies.push_back(proxy)


# TODO: when the card is hovered and another is added, 
# the returning animation sets obj to the wrong (previous) position
# @warn: animation is currently not supported, but 
# both AnimationPlayer and Tween will likely be
func add_card(card, redraw=true) -> Array:
	if card in _cards:
		return []
	_add_card(card)
	if redraw:
		draw_cards()
	return utils.get_placement_coeffs(_proxies, true)


# @warn: animation is currently not supported, but 
# both AnimationPlayer and Tween will likely be
func add_cards(cards: Array, redraw=true) -> Array:
	var last_placement = []
	for card in cards:
		if not card in _cards:
			last_placement = _add_card(card)
	if redraw:
		draw_cards()
	return last_placement


# @warn: animation is currently not supported, but 
# both AnimationPlayer and Tween will likely be
func remove_card(card, redraw=true) -> Transform:
	if not card in _cards:
		# null?
		return Transform.IDENTITY
	var proxy = card.get_parent()
	# remove all connections between proxy and hand
	proxy.set_collision_layer_bit(_collision_layer_bit, false)
	_hovered = null
	_proxies.erase(proxy)
	# remove the connection between proxy and its obj
	var card_trans = proxy.remove_from(card, get_parent())
	# say goodbye to proxy
	proxy.queue_free()

	_cards.erase(card)
	if redraw:
		# update visual
		draw_cards()
	return card_trans


func draw_cards():
	var trans: Transform
	var coeffs = utils.get_placement_coeffs(_cards)
	for i in coeffs.size():
		# place the center of the cards on the line
		trans = _proxies[i].get_transform()
		trans.origin = coeffs[i][0]
		# rotate the card
		trans.basis = Basis.IDENTITY.rotated(Vector3.UP, -coeffs[i][1])
		_proxies[i].set_transform(trans)
		# set the original transform (position + rotation)
		_proxies[i].set_orig_trans(trans)


func highlight():
	highlighter.highlight()


func cancel_highlight():
	highlighter.cancel_highlight()


func get_card_list():
	return _cards


func has_obtainable_cards(hp_state):
	for card in _cards:
		if card.card_config.play_cost.is_obtainable(hp_state):
			return true
	return false


func _on_hand_cell_input_event(proxy, event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == BUTTON_LEFT:
			emit_signal("hand_left_click", proxy, proxy.get_occupant())
		elif event.get_button_index() == BUTTON_RIGHT:
			emit_signal("hand_right_click", proxy, proxy.get_occupant())
