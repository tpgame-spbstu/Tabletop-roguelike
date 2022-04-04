extends Reference
# class_name MapLocation


var scene : String
var params : Dictionary
var pos: Vector2


func _init(scene : String, params : Dictionary, pos: Vector2):
	# scene to be opened
	self.scene = scene
	self.params = params
	# position of the current location
	self.pos = pos
