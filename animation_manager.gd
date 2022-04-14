extends Node

var animation_list = []


func _process(delta):
	var i = 0
	while i < animation_list.size():
		var animation = animation_list[i]
		if animation.process(delta):
			animation_list.remove(i)
			animation.emit_signal("animation_ended")
		else:
			i += 1


func add_animation(animation):
	animation_list.append(animation)
