extends Reference

class_name LinMoveAnimation


var start_transform : Transform
var end_transform : Transform
var duration : float
var spatial : Spatial
var progress : float = 0.0


func _init(start_transform : Transform, end_transform : Transform, duration : float, spatial : Spatial):
	self.start_transform = start_transform
	self.end_transform = end_transform
	self.duration = duration
	self.spatial = spatial

func process(delta : float) -> bool:
	progress += delta / duration
	if progress >= 1.0:
		progress = 1.0
	spatial.global_transform = start_transform.interpolate_with(end_transform, progress)
	if progress == 1.0:
		return true
	return false
