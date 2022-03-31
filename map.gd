extends Spatial

signal return_to_main_menu()

var GameConfig = load("res://game_config.gd")
var game_config
var map_config
var current_map_point
onready var character = $character

const SPACE = 15.0



func initialize(game_config):
	$character/Camera.make_current()
	assert(game_config != null)
	assert(game_config.map_config != null)
	assert(game_config.deck_config != null)
	self.game_config = game_config
	map_config = game_config.map_config
	generate_points()
	character.transform = current_map_point.transform
	

func _ready():
	pass


func generate_points():
	var destinations = $Destinations
	var map_ponit_scene = load("res://map_point.tscn")
	var location = map_config.map_location_grapth
	while true:
		var point = map_ponit_scene.instance()
		if map_config.current_map_location == location:
			current_map_point = point
		destinations.add_child(point)
		point.translate(Vector3(location.x_position, 0, location.y_position) * SPACE)
		point.initialize(self, location)
		if location.next_locations.size() == 0:
			break
		location = location.next_locations[0]
	
	return

var waiting_animation := false

func _on_map_point_click(map_point):
	if waiting_animation:
		return
	if map_point.map_location in map_config.current_map_location.next_locations:
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
		yield(cur_location_scene, "return_to_map")
		cur_location_scene.queue_free()
		self.show()
		$character/Camera.make_current()
		print("next")
