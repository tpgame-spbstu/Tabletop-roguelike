extends Spatial

signal return_to_main_menu()

var GameConfig = load("res://game_config.gd")
var game_config
var map_config
var current_map_point
var PathSection = load("res://Map/Path/path_section.tscn")
onready var Paths = $Paths
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

	for tile in map_config.map_location_graph:
		var point = map_point_scene.instance()
		# if this tile is the starting point
		if tile == map_config.current_map_location:
			current_map_point = point
		destinations.add_child(point)
		# put the tile on the map
		point.translate(Vector3(tile.pos.x, 0, tile.pos.y) * SPACE)
		# initialize the tile
		point.initialize(self, tile)

		# draw the paths
		for dest in map_config.map_location_graph[tile]:
			var path_sec = PathSection.instance()
			var dx = (dest.pos.x - tile.pos.x) * SPACE
			var dy = (dest.pos.y - tile.pos.y) * SPACE
			# rotate the section
			# ATTENTION the rotation is done clockwise, not anticlockwise
			var angle = -PI / 2
			if dx != 0:
				var alpha = abs(dy / dx)
				angle = atan(-alpha if dx * dy > 0 else alpha)
			path_sec.rotate_y(angle)

			# put the section's center to the medium point of the line between two locations' points
			path_sec.set_translation(Vector3((tile.pos.x + dest.pos.x)/ 2, 0, (tile.pos.y + dest.pos.y) / 2) * SPACE)

			var scale: Vector3 = path_sec.get_scale()
			# | | -> |     |, | is PATH_WIDTH, z^->x
			path_sec.set_scale(Vector3(sqrt(pow(dx, 2) + pow(dy, 2) - pow(PATH_WIDTH, 2)), scale.y, PATH_WIDTH))

			Paths.add_child(path_sec)



var waiting_animation := false

func _on_map_point_click(map_point):
	if waiting_animation:
		return

	# if the path from the current location to the clicked one exists
	if map_point.map_location in map_config.map_location_graph[current_map_point.map_location]:
		character.animation = LinMoveAnimation.new(current_map_point.global_transform, 
			map_point.global_transform, 1.0, character)

		waiting_animation = true
		yield(character, "animation_ended")
		waiting_animation = false

		map_config.current_map_location = map_point.map_location
		current_map_point = map_point

		var cur_location_scene = load(map_config.current_map_location.scene).instance()
		get_parent().add_child(cur_location_scene)
		cur_location_scene.initialize(game_config.deck_config, game_config.inventory_config, map_config.current_map_location.params)
		self.hide()
		var is_win = yield(cur_location_scene, "return_to_map")
		cur_location_scene.queue_free()
		self.show()
		get_node("character/Camera").make_current()
		if !is_win:
			emit_signal("return_to_main_menu")
		GameLoadManager.save_game(game_config)
