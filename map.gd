extends Spatial

signal return_to_main_menu()

var MapLocation = load("res://map_location.gd")
var MapConfig = load("res://map_config.gd")
var GameConfig = load("res://game_config.gd")
var game_config
var map_config
var temp_map_config
var current_map_point
onready var character = $character

const SPACE = 15.0

func init_temp_map_config():
	var loc4 = MapLocation.new("res://location.tscn", {}, [], -1, 3)
	var loc3 = MapLocation.new("res://location.tscn", {}, [loc4], 1, 2)
	var loc2 = MapLocation.new("res://location.tscn", {}, [loc3], 1, 1)
	var loc1 = MapLocation.new("", {}, [loc2], 0, 0)
	temp_map_config = MapConfig.new()
	temp_map_config.map_location_grapth = loc1
	temp_map_config.current_map_location = loc1


func initialize(game_config):
	if game_config == null:
		game_config = GameConfig.new()
	if game_config.map_config == null:
		init_temp_map_config()
		game_config.map_config = temp_map_config
	self.game_config = game_config
	

func _ready():
	initialize(null)
	map_config = game_config.map_config
	generate_points()
	character.transform = current_map_point.transform

class LinMoveAnimation:

	var start_transform : Transform
	var end_transform : Transform
	var speed : float
	var spatial : Spatial
	var progress : float = 0.0


	func _init(start_transform : Transform, end_transform : Transform, speed : float, spatial : Spatial):
		self.start_transform = start_transform
		self.end_transform = end_transform
		self.speed = speed
		self.spatial = spatial

	func process(delta : float) -> bool:
		progress += delta * speed
		if progress >= 1.0:
			progress = 1.0
		spatial.global_transform = start_transform.interpolate_with(end_transform, progress)
		if progress == 1.0:
			return true
		return false


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
		
		var cur_scene = load(map_config.current_map_location.scene).instance()
		get_tree().get_root().add_child(cur_scene)
		cur_scene.initialize(self, null, null, {})
		# get_tree().change_scene_to(cur_scene)
		self.set_visible(false)
		print("next")
		# yield(cur_scene, "return_to_map")
		

func _on_location_return_to_map():
	self.set_visible(true)
	
