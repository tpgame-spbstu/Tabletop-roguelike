extends Spatial

#Bell class - symple 3d scene object, that can be clicked

signal bell_click(bell)
onready var animation = $AnimationPlayer
onready var sound_hit = $AudioStreamPlayer3D
onready var timer = $Timer
const TIME_WAIT = 1.2


func play_hit_animation():
	animation.play("hit")
	sound_hit.play()
	timer.start(TIME_WAIT)
	yield(timer, "timeout")


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == BUTTON_LEFT:
			emit_signal("bell_click", self)
