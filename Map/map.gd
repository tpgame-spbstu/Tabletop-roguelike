extends Spatial

signal return_to_main_menu(result)

var GameConfig = load("res://game_config.gd")
var game_config
var map_config
var current_map_point
var PathSection = load("res://Map/Path/path_section.tscn")
var utils = preload("res://Map/utils.gd").new()
# stores paths between points
# [[start_vertex, end_vertex]]: path
var _paths = Dictionary()
# [point]: [other points, this one connects to]
var _graph = Dictionary()
# [point_config]: point
var _points = Dictionary()
onready var character = $character
enum _MapState { BLOCKED, MOVING, CHOOSING}
var _state

export(Color) var unreachable_edge_color = Color(0.5, 0.5, 0.5, 0.5)
export(Color) var reachable_edge_color = Color(1, 1, 1, 1)
export(float, 0.1, 5.0, 2.0) var PATH_WIDTH = 2
export(float, 1.0, 30.0, 15.0) var SPACE = 15.0


func initialize(game_config):
	get_node("character/Camera").make_current()
	
	assert(game_config != null)
	assert(game_config.map_config != null)
	assert(game_config.deck_config != null)
	
	self.game_config = game_config
	map_config = game_config.map_config
	
	_generate_points()
	_repaint_paths_availablility()
	
	character.transform = current_map_point.transform
	if current_map_point.map_point_config.is_visited():
		set_choosing_state()
	else:
		set_blocked_state()


func set_choosing_state():
	$map_gui/tip.hide()
	_state = _MapState.CHOOSING
	# highlight all the points, the current node has paths to
	_highlight_points(current_map_point)


func set_blocked_state():
	$map_gui/tip.hide()
	current_map_point.mark_current()
	current_map_point.highlight()
	_state = _MapState.BLOCKED


func set_moving_state():
	$map_gui/tip.hide()
	_state = _MapState.MOVING


func show():
	.show()
	$map_gui.show()

func hide():
	.hide()
	$map_gui.hide()
	


"""
	Generates tiles on the map
"""
func _generate_points() -> void:
	# load the scene, representing the location tile on the map
	var map_point_scene = load("res://Map/Location/map_point.tscn")

	for point_config in map_config.map_point_graph:
		var point = map_point_scene.instance()
		# if this tile is the starting point
		if point_config == map_config.current_map_point_config:
			current_map_point = point
		add_child(point)
		# put the tile on the map
		point.translate(Vector3(point_config.pos.x, 0, point_config.pos.y) * SPACE)
		# initialize the map_point
		point.initialize(self, point_config)
		point.lowlight()

		# crutch as I need to highlight points, not point_configs
		_points[point_config] = point

		_add_paths(point_config)
	
	for point in _points.values():
		_graph[point] = []
		for dest_conf in map_config.map_point_graph[point.map_point_config]:
			_graph[point].append(_points[dest_conf])


func _add_paths(p_conf):
	# draw the paths
	for dest in map_config.map_point_graph[p_conf]:
		var path_sec = PathSection.instance()
		var dx = (dest.pos.x - p_conf.pos.x) * SPACE
		var dy = (dest.pos.y - p_conf.pos.y) * SPACE
		# rotate the section
		# ATTENTION the rotation is done clockwise, not anticlockwise
		var angle = -PI / 2
		if dx != 0:
			var alpha = abs(dy / dx)
			angle = atan(-alpha if dx * dy > 0 else alpha)
		path_sec.rotate_y(angle)

		# put the section's center to the medium point of the line between two locations' points
		path_sec.set_translation(Vector3((p_conf.pos.x + dest.pos.x)/ 2, 0, (p_conf.pos.y + dest.pos.y) / 2) * SPACE)

		var scale: Vector3 = path_sec.get_scale()
		# | | -> |     |, | is PATH_WIDTH, z^->x
		path_sec.set_scale(Vector3(sqrt(pow(dx, 2) + pow(dy, 2) - pow(PATH_WIDTH, 2)), scale.y, PATH_WIDTH))

		_paths[[p_conf, dest]] = path_sec
		add_child(path_sec)


## repaints paths for current_map_point
##
## @desc: repaints reachable and unreachable paths with proper color
##        no side effects (doesn't mess the map_config.map_config_graph up)
func _repaint_paths_availablility():
	# Firstly, paint all paths as unreachable
	var all_paths = _paths.values()
	for path in all_paths:
		utils.change_mat_color(path.get_mesh(), unreachable_edge_color)
	
	# Secondly, paint all reachable from current point paths
	# using depth-first graph traversal
	var p_to_process = [current_map_point]
	# A list to prevent repetitions and cycles
	var p_processed = []
	
	while not p_to_process.empty():
		var p = p_to_process.pop_back()
		
		for dest in _graph[p]:
			assert(dest != p)
			var path = _paths[[p.map_point_config, dest.map_point_config]]
			
			utils.change_mat_color(path.get_mesh(), reachable_edge_color)
			
			if dest in p_to_process or dest in p_processed:
				continue
			p_to_process.push_back(dest)
		
		p_processed.push_back(p)


## highlight all the points, that have paths from the `point`
func _highlight_points(point):
	for p in _graph[point]:
		p.highlight()


## lowlight all the points, that have paths from the `point`
func _lowlight_points(point):
	for p in _graph[point]:
		p.lowlight()


func move_to_next_point(map_point):
	# lowlight all the vertexes, that has paths from the current (not the one pressed) vertex
	_lowlight_points(current_map_point)
	# Wait for character move animation
	var animation = SmoothMoveAnimation.new(current_map_point.global_transform, 
		map_point.global_transform, 1.0, character)
	AnimationManager.add_animation(animation)
	set_moving_state()
	yield(animation, "animation_ended")
	# Change current map point
	map_config.current_map_point_config = map_point.map_point_config
	current_map_point = map_point
	_repaint_paths_availablility()
	set_blocked_state()


func explore_location():
	# Load next location scene
	var cur_location_scene = load(current_map_point.map_point_config.scene).instance()
	get_parent().add_child(cur_location_scene)
	cur_location_scene.initialize(game_config.deck_config, 
		game_config.inventory_config, current_map_point.map_point_config.params)
	# Hide map and wait for exit from location
	self.hide()
	var result = yield(cur_location_scene, "return_to_map")
	# Delete location and show map
	cur_location_scene.queue_free()
	self.show()

	current_map_point.lowlight()

	get_node("character/Camera").make_current()
	# Process location interaction result
	match result:
		"win":
			pass
		"lose":
			emit_signal("return_to_main_menu", "lose")
			return
		"main_menu":
			emit_signal("return_to_main_menu")
			return
		_:
			pass
	current_map_point.mark_visited()
	set_choosing_state()
	GameLoadManager.save_game(game_config)


func _on_map_point_click(map_point):
	match(_state):
		_MapState.CHOOSING:
			# if the path from the current location to the clicked one exists
			if map_point in _graph[current_map_point]:
				move_to_next_point(map_point)
		_MapState.BLOCKED:
			if map_point == current_map_point:
				explore_location()


func _on_map_point_mouse_entered(map_point):
	if _state == _MapState.BLOCKED and map_point == current_map_point:
		$map_gui/tip.show_tip("Исследовать")
		return
	if (_state == _MapState.CHOOSING and map_point in _graph[current_map_point]):
		$map_gui/tip.show_tip("Идти дальше")
		return


func _on_map_point_mouse_exited(map_point):
	$map_gui/tip.hide()


func _on_main_menu_button_pressed():
	if _state != _MapState.MOVING:
		emit_signal("return_to_main_menu", "return")
