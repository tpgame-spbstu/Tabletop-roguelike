extends StaticBody

signal _mouse_entered(card)
signal _mouse_exited(card)

# original position regarding the animations (= position before the animation)
var _orig_pos: Vector3 setget set_orig_pos, get_orig_pos
# tween that is started on hovering
onready var _hover_tween: HoverTween setget , get_hower_tween


func _ready():
	_hover_tween = HoverTween.new()
	add_child(_hover_tween)
	# will use to set the internal state of the tween to NONE
	_hover_tween.connect("tween_all_completed", self, "_on_hover_tween_complete")
	_hover_tween.set_state(_hover_tween.NONE)

	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _on_mouse_entered():
	print("Mouse!")
	emit_signal("_mouse_entered", self)


func _on_mouse_exited():
	emit_signal("_mouse_exited", self)


func _on_hover_tween_complete():
	_hover_tween.set_state(_hover_tween.NONE)


func get_hower_tween():
	return _hover_tween


func set_orig_pos(pos):
	_orig_pos = pos
	print("orig: ", _orig_pos)


func get_orig_pos():
	return _orig_pos
