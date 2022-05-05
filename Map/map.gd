extends Spatial

signal return_to_main_menu(result)

var GameConfig = load("res://game_config.gd")
var game_config
var map_config
var current_map_point
var PathSection = load("res://Map/Path/path_section.tscn")
var utils = preload("res://Map/utils.gd").new()
# stores the number of paths, that enters the vertex
var _semi_enters = Dictionary()
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

export(Color) var unreachable_edge_color = Color(0.2, 0.2, 0.2, 0.2)
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
	# highlight all the points, the current node has paths to
	_highlight_points(current_map_point.map_point_config)
	
	character.transform = current_map_point.transform
	if current_map_point.map_point_config.is_visited():
		set_choosing_state()
	else:
		set_blocked_state()


func set_choosing_state():
	$map_gui/explore_location_button.hide()
	_state = _MapState.CHOOSING


func set_blocked_state():
	$map_gui/explore_location_button.show()
	_state = _MapState.BLOCKED


func set_moving_state():
	$map_gui/explore_location_button.hide()
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
			# special case: there is no path to the starting vertex, 
			# hence no 'graph traversal'
			current_map_point.lowlight()
		add_child(point)
		# put the tile on the map
		point.translate(Vector3(point_config.pos.x, 0, point_config.pos.y) * SPACE)
		# initialize the map_point
		point.initialize(self, point_config)

		# crutch as I need to highlight points, not point_configs
		_points[point_config] = point

		_add_paths(point_config)
	# graph is built only after all the map_points are iterated over
	# lowlight every vertex
	for p_conf in _points:
		_lowlight_points(p_conf)


func _add_paths(p_conf):
	# draw the paths
	for dest in map_config.map_point_graph[p_conf]:
		_semi_enters[dest] = _semi_enters.get(dest, 0) + 1

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


## removes paths from available ones
##
## @desc: paints the unavailable paths with different color
##        no side effects (doesn't mess the map_config.map_config_graph up)
func _remove_paths(graph, curr, next):
	var to_remove = Array()
	# fill the array with all the vertexes, available from this one
	# except the next one (clicked)
	for p in graph[curr]:
		if p != next:
			to_remove.push_back([curr, p])

	# remove all unreachable paths: if there was only one edge to the vertex,
	# edges from it should also be removed
	while to_remove:
		var edge = to_remove.pop_back()
		var f = edge[0]
		var s = edge[1]
		# about to remove the entering edge
		_semi_enters[s] -= 1
		# if there is no way to enter this vertex
		if not _semi_enters[s]:
			# push all the vertexes, available from this one: they're unreachable
			for _s in graph[s]:
				to_remove.push_back([s, _s])
		# change the color of unreachable edges
		var path = _paths[edge]
	# set the path from the current point to the clicked one
		utils.change_mat_color(path.get_mesh(), unreachable_edge_color)
	# as unreachable
	var mesh = _paths[[curr, next]].get_mesh()

	utils.change_mat_color(mesh, unreachable_edge_color)


## highlight all the points, that have paths from the `p_conf`
func _highlight_points(p_conf):
	for p in map_config.map_point_graph[p_conf]:
		_points[p].highlight()


## lowlight all the points, that have paths from the `p_conf`
func _lowlight_points(p_conf):
	for p in map_config.map_point_graph[p_conf]:
		_points[p].lowlight()


func _on_map_point_click(map_point):
	if _state != _MapState.CHOOSING:
		return

	# if the path from the current location to the clicked one exists
	if map_point.map_point_config in map_config.map_point_graph[current_map_point.map_point_config]:
		_remove_paths(map_config.map_point_graph, current_map_point.map_point_config, map_point.map_point_config)
		# lowlight all the vertexes, that has paths from the current (not the one pressed) vertex
		_lowlight_points(current_map_point.map_point_config)
		# Wait for character move animation
		var animation = LinMoveAnimation.new(current_map_point.global_transform, 
			map_point.global_transform, 1.0, character)
		AnimationManager.add_animation(animation)
		set_moving_state()
		yield(animation, "animation_ended")
		# Change current map point
		map_config.current_map_point_config = map_point.map_point_config
		current_map_point = map_point
		set_blocked_state()


func _on_main_menu_button_pressed():
	if _state != _MapState.MOVING:
		emit_signal("return_to_main_menu", "return")


func _on_explore_location_button_pressed():
	if _state != _MapState.BLOCKED:
		return
	# Load next location scene
	var cur_location_scene = load(map_config.current_map_point_config.scene).instance()
	get_parent().add_child(cur_location_scene)
	cur_location_scene.initialize(game_config.deck_config, 
		game_config.inventory_config, map_config.current_map_point_config.params)
	# Hide map and wait for exit from location
	self.hide()
	var result = yield(cur_location_scene, "return_to_map")
	# Delete location and show map
	cur_location_scene.queue_free()
	self.show()

	current_map_point.mark_visited()
	# highlight all the vertexes from the current (the one pressed) vertex
	_highlight_points(current_map_point.map_point_config)

	get_node("character/Camera").make_current()
	# Process location interaction result
	match result:
		"win":
			pass
		"lose":
			emit_signal("return_to_main_menu", "lose")
			return
		_:
			pass
	set_choosing_state()
	GameLoadManager.save_game(game_config)
