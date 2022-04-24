extends Spatial


signal mouse_entered(card)
signal mouse_exited(card)

# stores the cards
var _cards: Array
var _hovered
onready var card_inst = load("res://Modification/card_3d.tscn")
# TODO: substitute, change it with the actual value
const OFFSET := Vector3(0, 0.5, 0)

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
		card_inst.instance()
	]
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	initialize(cards)
	draw_cards()


# func _process(delta: float):
#   print("mouse pos: ", get_global_mouse_position())

func _input(event):
	if event is InputEventMouseMotion:
		# print("mouse pos: ", event.position)
		# print("glogal mouse pos: ", event.global_position)
		var cam = $Camera
		# print("cam y: ", cam.get_camera_transform().origin.y)
		# print("projected: ", cam.project_position(event.global_position, cam.get_camera_transform().origin.y))
		# print("parent pos: ", get_transform().origin)
		# print("card 0 pos: ", _cards[0].get_global_transform().origin)

		var mouse_pos = get_viewport().get_mouse_position()
		var ray_from = $Camera.project_ray_origin(mouse_pos)
		# print("mouse_pos: ", mouse_pos)
		# print("ray_from: ", ray_from)
		var RAY_LENGTH = 1000
		var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * RAY_LENGTH
		var space_state = get_world().direct_space_state
		
		var first_card = space_state.intersect_ray(ray_from, ray_to)
		if first_card:
			first_card = first_card["collider"]
			# print("first_card: ", first_card)
			if not _hovered:
				_hovered = first_card
				emit_signal("mouse_entered", first_card)
			else:
				if first_card != _hovered:
					emit_signal("mouse_exited", _hovered)
					_hovered = first_card
					emit_signal("mouse_entered", first_card)
					return
				var second_card = space_state.intersect_ray(ray_from, ray_to, [_hovered])
				if second_card:
					second_card = second_card["collider"]
					if second_card == first_card:
						print(_hovered)
						print(first_card, second_card)
						print("s = f")
						return
					if second_card == _hovered:
						print("s = h")
					var poly1 = first_card._get_2dpoints()
					var poly2 = second_card._get_2dpoints()

					var inter = Geometry.intersect_polygons_2d(poly1, poly2)
					if inter:
						# var line = ImmediateGeometry.new()
						# var ig = ImmediateGeometry.new()
						# add_child(line)
						# add_child(ig)
						var line = $line
						var ig = $ig
						ig.clear()
						line.clear()
						ig.begin(Mesh.PRIMITIVE_LINE_LOOP)
						var _p
						var _x = 0
						var _y = 0
						var _xy = 0
						var _x2 = 0
						var _y2 = 0
						var n = 0
						for p in inter[0]:
							_p = Vector3(p.x, 2, p.y)
							_x += p.x
							_y += p.y
							_xy += p.x*p.y
							_x2 += pow(p.x, 2)
							_y2 += pow(p.y, 2)
							n += 1
							ig.add_vertex(_p)
						ig.end()
						var a = (n * _xy - _x * _y) / (n * _y2 - pow(_y, 2))
						var b = (_x - a * _y) / n

						var p1 = Vector3(a * 30 + b, 2, 30)
						var p2 = Vector3(a * -30 + b, 2, -30)

						line.begin(Mesh.PRIMITIVE_LINE_LOOP)
						line.add_vertex(p1)
						line.add_vertex(p2)
						line.end()

						var mouse_local_pos = Vector2(ray_to.x, ray_to.z)
						var first_card_trans = first_card.get_translation()
						var first_card_pos = Vector2(first_card_trans.x, first_card_trans.z)

						if a * first_card_pos.y + b < first_card_pos.x and a * mouse_local_pos.y + b >= mouse_local_pos.x or \
							a * first_card_pos.y + b >= first_card_pos.x and a * mouse_local_pos.y + b < mouse_local_pos.x:
							emit_signal("mouse_exited", first_card)
							emit_signal("mouse_entered", second_card)
							_hovered = second_card

						# print(a * first_card_pos.y + b, " ", first_card_pos.x, ", mouse: ", a*mouse_local_pos.y + b, ", ", mouse_local_pos.x)
						# print("ray to: ", ray_to)
						# print(first_card.get_translation())
						# $point.set_translation(Vector3(-7.925, 2, 0.925))
						# print($point.get_translation())


		elif _hovered and not first_card:
			emit_signal("mouse_exited", _hovered)
			_hovered = null



		#     first_card = first_card["collider"]
		#     var second_card = space_state.intersect_ray(ray_from, ray_to, [_hovered])
		#     if second_card:
		#         print("here")
		#         second_card = second_card["collider"]
		#         emit_signal("mouse_exited", first_card)
		#         emit_signal("mouse_entered", second_card)
		# elif _hovered:
		#     emit_signal("mouse_exited", _hovered[0])

		# if first_card and not second_card:
		#     first_card.emit_signal("_mouse_entered", first_card)
		# elif first_card and second_card:
		#     second_card.emit_signal("_mouse_entered", second_card)
		# else:
		#     for card in _hovered:
		#         card.emit_signal("_mouse_exited", card)
		# print(_hovered)
		# print(first_card)
		# print(second_card)
		# if second_card:
		#     if second_card["collider"] in _cards:
		#         print("Hit!")
		#     second_card["collider"].emit_signal("_mouse_entered", second_card["collider"])
		# else:
		#     for _card in _hovered:
		#         if second_card and _card != second_card["collider"]:
		#             print("emited")
		#             _card.emit_signal("_mouse_exited", _card)


func initialize(cards: Array):
	_cards = cards.duplicate()
	# add all the cards as children to the root
	for card in _cards:
		add_child(card)
		# connect("mouse_entered", self, "_on_mouse_entered")
		# connect("mouse_exited", self, "_on_mouse_exited")
		# card.connect("_mouse_entered", self, "_on_mouse_entered")
		# card.connect("_mouse_exited", self, "_on_mouse_exited")


func draw_cards():
	var rad_from := -PI + TAU / 12
	var rad_to := -TAU / 12
	var r = 10
	var pos := Vector3(0, 0, 7)
	var dh = 0.01

	var cur_rad: float
	var cols = [Color.green, Color.black, Color.white, Color.magenta, Color.aqua, Color.blueviolet, Color.chocolate, Color.cornflower, Color.crimson, Color.darkcyan, Color.darkorange, Color.red]
	for i in _cards.size():
		cur_rad = rad_from + i * (rad_to - rad_from) / (_cards.size() - 1)
		_cards[i].translate(pos + Vector3(cos(cur_rad), i * dh, sin(cur_rad)) * r)
		# print(_cards[i].get_translation())
		_cards[i].set_orig_pos(_cards[i].get_translation())
		var e = _cards[i].rotation
		# print("before ", rad2deg(e.x), " ", rad2deg(e.y), " ", rad2deg(e.z))

		# _cards[i].rotate(Vector3.UP, -cur_rad - TAU / 4)

		# e = _cards[i].rotation
		# print("after ", rad2deg(e.x), " ", rad2deg(e.y), " ", rad2deg(e.z))
		# print(_cards[i].rotation)
		# print(_cards[i].global_transform.basis.get_euler())
		# print(_cards[i].global_transform.basis.get_euler().angle_to(Vector3.RIGHT))
		
		# print(_cards[i]._get_2dpoints())
#         var j = 0
#         for p in _cards[i]._get_points():
#             var s = $point.duplicate()
#             add_child(s)
#             var mesh = s.mesh.duplicate()
#             var mat = mesh.material.duplicate()
#             mat.albedo_color = cols[i %  cols.size()]
#             mesh.set_material(mat)
#             s.set_mesh(mesh)
# #            print("local ", p)
# #            print("global ", _cards[i].to_local(p))
#             s.translate(p)
#             s.show()
#             j+= 1
#         # break
#     $point.hide()
#     for i in _cards.size() - 1:
#         var poly = Geometry.intersect_polygons_2d(_cards[i]._get_2dpoints(), _cards[i + 1]._get_2dpoints())
#         var ma = Vector2.ZERO
#         var mi = Vector2.ZERO
#         var line = ImmediateGeometry.new()
#         var ig = ImmediateGeometry.new()
#         add_child(line)
#         add_child(ig)
#         # var ig = $draw
#         ig.clear()
#         line.clear()
#         ig.begin(Mesh.PRIMITIVE_LINE_LOOP)
#         var _p
#         var rot = _cards[i].get_rotation().y
#         var _x = 0
#         var _y = 0
#         var _xy = 0
#         var _x2 = 0
#         var _y2 = 0
#         var n = 0
#         for p in poly[0]:
#             _p = Vector3(p.x, 2, p.y)
#             _x += p.x
#             _y += p.y
#             _xy += p.x*p.y
#             _x2 += pow(p.x, 2)
#             _y2 += pow(p.y, 2)
#             n += 1
#             # _p = _p.rotated(Vector3.UP, -rot)
#             # ig.add_vertex(Vector3(p.x, 2, p.y))
#             ig.add_vertex(_p)
#             # if _p.x > ma.x:
#             #     ma.x = _p.x
#             # if _p.y > ma.y:
#             #     ma.y = _p.y
#             # if _p.x < mi.x:
#             #     mi.x = _p.x
#             # if _p.y < mi.y:
#             #     mi.y = _p.y
#         ig.end()
#         # print(poly, ma, mi)
#         var a = (n * _xy - _x * _y) / (n * _y2 - pow(_y, 2))
#         var b = (_x - a * _y) / n

#         var p1 = Vector3(a * 30 + b, 2, 30)
#         var p2 = Vector3(a * -30 + b, 2, -30)


#         line.begin(Mesh.PRIMITIVE_LINE_LOOP)
#         line.add_vertex(p1)
#         line.add_vertex(p2)
#         # line.add_vertex(Vector3(ma.x, 2, ma.y))#.rotated(Vector3.UP,rot))
#         # line.add_vertex(Vector3(ma.x, 2, mi.y))#.rotated(Vector3.UP,rot))
#         # line.add_vertex(Vector3(mi.x, 2, mi.y))#.rotated(Vector3.UP,rot))
#         # line.add_vertex(Vector3(mi.x, 2, ma.y))#.rotated(Vector3.UP,rot))
#         # line.add_vertex(Vector3((ma.x + mi.x) / 2, 2, ma.y))
#         # line.add_vertex(Vector3((ma.x + mi.x) / 2, 2, mi.y))
#         line.end()

func _on_mouse_entered(card):
	var tween = card.get_hower_tween()
	tween.on_enter(OFFSET)
	# _hovered.append(card)


func _on_mouse_exited(card):
	var tween = card.get_hower_tween()
	tween.on_exit()
	# _hovered.erase(card)
