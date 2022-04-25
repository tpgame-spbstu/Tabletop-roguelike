extends Spatial


signal mouse_entered(card)
signal mouse_exited(card)

# stores the cards
var _cards: Array
# stores currently hovered card
var _hovered
# set for every card, ray is also checking only this layer
# done to avoid ray picking cards, that are not in the hand
var _collision_layer_bit: int = 2
onready var card_inst = load("res://Modification/card_3d.tscn")
onready var utils = load("res://Modification/utils.gd").new()
# TODO: substitute, change it with the actual value
const OFFSET := Vector3(0, 0.5, -2.5)
# -15 degrees
const PHI := -6.2830 / 24
# coeff to put the cards on the edges lower, than the cards in the middle
const FUNC_COEFF := 7.5


func _ready():
	var cards = [
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
		card_inst.instance(),
	]
	initialize(cards)


func _notification(what):
	match what:
		# if the card was hovered, it remains in hovered state
		# when the window is minimized, mouse position is not updated
		# so clean up the hovered
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if _hovered:
				emit_signal("mouse_exited", _hovered)


## checks whether the hovered card and the current mouse position are on the different
## sides of the line
##
## @desc: in order to make the transition from hovered card to the one under it, an intersecting
##        polygon is created. It is split in two halves (almost) using `least square regression`.
##        if the hovered card is on one side of the regression line while the mouse position is on the other,
##        then one needs to make the card, on which the mouse is on, hovered,
##        and the one hovered at the moment unhovered
##
## :line_coeffs: coeffs of the line
## :card_pos: position of the hovered card
## :mouse_pos: position of the mouse
##
## :return: true, if on the opposite sides of the line, false otherwise
func _is_hovering_new_card(line_coeffs: Vector2, card_pos: Vector2, mouse_pos: Vector2):
	return utils.get_line_sign(line_coeffs, card_pos) * utils.get_line_sign(line_coeffs, mouse_pos) < 0


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
func _mouse_hovering(event):
	# set-up for intersecting cards under the mouse
	var cam = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = cam.project_ray_origin(mouse_pos)
	# value is big enough to get any intersection
	# though the cards are in between [0, 2] on Y-axis
	var RAY_LENGTH = 1000
	var ray_to = ray_from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state

	# get the closest (highest on Y-axis) card under the mouse
	var first_card = space_state.intersect_ray(ray_from, ray_to, [], _get_collision_layer())
	if first_card:
		first_card = first_card["collider"]
		# case (2)
		# if not taking into account the tween, recursion between cases 2 and 3
		if not _hovered:
			if not first_card.get_hower_tween().is_active() or Geometry.is_point_in_polygon(Vector2(ray_to.x, ray_to.z), first_card._get_2dpoints()):
				emit_signal("mouse_entered", first_card)
		else:
			# case (6)
			if first_card != _hovered:
				emit_signal("mouse_exited", _hovered)
				emit_signal("mouse_entered", first_card)
				return
			# get the card under the first card, if any
			# [_hovered] means to ignore the hovered card during raycasting
			var second_card = space_state.intersect_ray(ray_from, ray_to, [_hovered], _get_collision_layer())
			if second_card:
				second_card = second_card["collider"]
				# get the polygons of the cards (array of their vertexes)
				var poly1 = first_card._get_2dpoints()
				var poly2 = second_card._get_2dpoints()
				var inter = Geometry.intersect_polygons_2d(poly1, poly2)
				# check whether the two cards intersect
				if inter:
					# get the centerline of the intersection area
					var line_coeffs = utils.least_squares_regression(inter[0])
					var mouse_local_pos = Vector2(ray_to.x, ray_to.z)
					var first_card_trans = first_card.get_translation()
					var first_card_pos = Vector2(first_card_trans.x, first_card_trans.z)

					# check whether the hovered card and the mouse are on different sides of the line
					if _is_hovering_new_card(line_coeffs, first_card_pos, mouse_local_pos):
						# case (5)
						emit_signal("mouse_exited", first_card)
						emit_signal("mouse_entered", second_card)
	# case (3)
	elif _hovered and not first_card:
		emit_signal("mouse_exited", _hovered)


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_hovering(event)


func initialize(cards: Array):
	_cards = cards.duplicate()
	# add all the cards as children to the root
	for card in _cards:
		add_child(card)
	# the card is passed, so connect only oneself
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	draw_cards()


func __f(x, coeff=60.0):
	return pow(x, 2) / coeff


func _get_placement_coeffs(get_last=false) -> Array:
	var coeffs: Array = []
	if _cards:
		var size = _cards[0].get_size() / 2  # get the size of the card (its mesh, actually)
		var n = _cards.size() - 1
		var coeff = FUNC_COEFF  # empirical coefficient to make the cards on the sides lower, then the cards in the middle
		var a = -(n + 1) * size.x / 2  # a in [a, b]
		var b = -a  # b in [a, b]
		var dh = size.y * 2  # delta height
		var phi = PHI  # -15 degrees
		var psi = -phi  # +15 degrees

		var start_ind = n if get_last else 0

		var cur_point: float  # current offset from a
		var cur_rad: float  # current angle in rads
		var trans: Transform
		# when there is only one card
		if not n:
			coeffs.push_back([Vector3(a, 0, __f(a, 1)), phi])
		else:
			for i in range(start_ind, _cards.size()):
				cur_point = a + i * 2 * b / n
				cur_rad = phi + i * 2 * psi / n
				coeffs.push_back([Vector3(cur_point, i * dh, __f(cur_point, n * coeff)), cur_rad])
	return coeffs[0] if get_last else coeffs


func draw_cards():
	var trans: Transform
	var coeffs = _get_placement_coeffs()
	for i in coeffs.size():
		# place the center of the cards on the line
		trans = _cards[i].get_transform()
		trans.origin = coeffs[i][0]
		# rotate the card
		trans.basis = Basis.IDENTITY.rotated(Vector3.UP, -coeffs[i][1])
		_cards[i].set_transform(trans)
		# set the original transform (position + rotation)
		_cards[i].set_orig_trans(trans)


func _on_mouse_entered(card):
	_hovered = card
	var tween = card.get_hower_tween()
	tween.on_enter(OFFSET)


func _on_mouse_exited(card):
	_hovered = null
	var tween = card.get_hower_tween()
	tween.on_exit()


func _get_collision_layer():
	return 1 << _collision_layer_bit


