extends Reference


var scene: String
var params: Dictionary
var pos: Vector2
# array of textures (as string paths to rss)
# one texture per surface
# whether the map_point was visited
var _is_visited: bool = false setget set_visited, is_visited
enum types_map {MOD, FIGHT}
var type

func _init(scene: String, params: Dictionary, pos: Vector2, type=types_map.FIGHT,
 is_visited: bool=false):
	# scene to be opened
	self.scene = scene
	self.type = type
	self.params = params
	# position of the current map point
	self.pos = pos
	_is_visited = is_visited


func set_visited(val: bool):
	_is_visited = val


func is_visited() -> bool:
	return _is_visited
