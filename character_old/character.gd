extends KinematicBody

var animation = null

signal animation_ended()

func _process(delta):
	if animation != null:
		if animation.process(delta):
			animation = null
			emit_signal("animation_ended")



















































"""
onready var points = get_node("../Destinations").get_children()
var cur_id = 0
var cur_point
##
var isFollow = false
var speed = 7
var target
var t = 0

# onready var map_locs = get_node("..").map_locations
# onready var cur_point = get_node(map_locs.point_on_map)
func _ready():
	cur_point = points[cur_id]

func _process(delta):
	t += delta
	if isFollow:
		var direct = Vector3()
		direct = self.transform.origin.linear_interpolate(target, t)
		self.move_and_slide(direct)


func _on_Point_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.get_button_mask() == BUTTON_LEFT:
			target = cur_point.transform.origin
			isFollow = true


func _on_Point_body_entered(body):
	t = 0
	cur_id += 1
	cur_point = points[cur_id] # get_node(map_locs.locations[0].point_on_map) 
	isFollow = false"""
