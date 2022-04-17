extends Reference


var scene: String
var params: Dictionary
var pos: Vector2
# array of textures (as string paths to rss)
# one texture per surface
var _textures: Array setget ,get_textures


func _init(scene: String, params: Dictionary, pos: Vector2, textures: Array=[]):
	# scene to be opened
	self.scene = scene
	self.params = params
	# position of the current map point
	self.pos = pos
	_textures = textures


func get_textures():
	return _textures
