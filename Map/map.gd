extends Spatial

signal return_to_main_menu()

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
var _unreachable_edge_color = Color(0.2, 0.2, 0.2, 0.2)
onready var character = $character

const PATH_WIDTH = 2
const SPACE = 15.0


func initialize(game_config):
	get_node("character/Camera").make_current()

	assert(game_config != null)
	assert(game_config.map_config != null)
	assert(game_config.deck_config != null)

	self.game_config = game_config
	map_config = game_config.map_config
	generate_points()
	current_map_point.mark_visited(false)
	character.transform = current_map_point.transform


func _ready():
	pass


"""
	Generates tiles on the map
"""
func generate_points() -> void:
	# Destinations are the nodes on the map, that represent the location,
	# they're added dynamically
	var destinations = $Destinations
	# load the scene, representing the location tile on the map
	var map_point_scene = load("res://Map/Location/map_point.tscn")

	for point_config in map_config.map_point_graph:
		var point = map_point_scene.instance()
		# if this tile is the starting point
		if point_config == map_config.current_map_point_config:
			current_map_point = point
		destinations.add_child(point)
		# put the tile on the map
		point.translate(Vector3(point_config.pos.x, 0, point_config.pos.y) * SPACE)
		# initialize the map_point
		point.initialize(self, point_config)

		# draw the paths
		for dest in map_config.map_point_graph[point_config]:
			_semi_enters[dest] = _semi_enters.get(dest, 0) + 1

			var path_sec = PathSection.instance()
			var dx = (dest.pos.x - point_config.pos.x) * SPACE
			var dy = (dest.pos.y - point_config.pos.y) * SPACE
			# rotate the section
			# ATTENTION the rotation is done clockwise, not anticlockwise
			var angle = -PI / 2
			if dx != 0:
				var alpha = abs(dy / dx)
				angle = atan(-alpha if dx * dy > 0 else alpha)
			path_sec.rotate_y(angle)

			# put the section's center to the medium point of the line between two locations' points
			path_sec.set_translation(Vector3((point_config.pos.x + dest.pos.x)/ 2, 0, (point_config.pos.y + dest.pos.y) / 2) * SPACE)

			var scale: Vector3 = path_sec.get_scale()
			# | | -> |     |, | is PATH_WIDTH, z^->x
			path_sec.set_scale(Vector3(sqrt(pow(dx, 2) + pow(dy, 2) - pow(PATH_WIDTH, 2)), scale.y, PATH_WIDTH))

			_paths[[point_config, dest]] = path_sec
			add_child(path_sec)


func __remove_paths(graph, curr, next):
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
		utils.change_mat_color(path.get_mesh(), _unreachable_edge_color)
	# set the path from the current point to the clicked one
	# as unreachable
	var mesh = _paths[[curr, next]].get_mesh()
	utils.change_mat_color(mesh, _unreachable_edge_color)


var waiting_animation := false


func _on_map_point_click(map_point):
	if waiting_animation:
		return

	# if the path from the current location to the clicked one exists
	if map_point.map_point_config in map_config.map_point_graph[current_map_point.map_point_config]:
		__remove_paths(map_config.map_point_graph, current_map_point.map_point_config, map_point.map_point_config)
		# Wait for character move animation
		var animation = LinMoveAnimation.new(current_map_point.global_transform, 
			map_point.global_transform, 1.0, character)
		AnimationManager.add_animation(animation)
		waiting_animation = true
		yield(animation, "animation_ended")
		waiting_animation = false
		# Change current map point
		map_config.current_map_point_config = map_point.map_point_config
		current_map_point = map_point
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

		get_node("character/Camera").make_current()
		# Process location interaction result
		match result:
			"win":
				pass
			"lose":
				emit_signal("return_to_main_menu")
				return
			_:
				pass
		GameLoadManager.save_game(game_config)
