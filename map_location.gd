extends Reference


var scene : String
var params : Dictionary
var next_locations : Array
var x_position : int
var y_position : int

func _init(scene : String, params : Dictionary,  
next_locations : Array, x_position : int, y_position : int):
	self.scene = scene
	self.params = params
	self.next_locations = next_locations
	self.x_position = x_position
	self.y_position = y_position
