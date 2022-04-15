extends Node

# AnimationManager class - singleton object, to process universal animations,
# like LinMoveAnimation

# List of animation in progress
var _animation_list = []


# Process all animations
func _process(delta):
	var i = 0
	while i < _animation_list.size():
		var animation = _animation_list[i]
		if animation.process(delta):
			# Animation is over
			_animation_list.remove(i)
			animation.emit_signal("animation_ended")
		else:
			i += 1


# Add simple animation
func add_animation(animation):
	_animation_list.append(animation)
