extends Control


func _input(event):
	if event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		rect_global_position = motion_event.global_position


func show_tip(tip_text):
	$tip_lable.text = tip_text
	show()
