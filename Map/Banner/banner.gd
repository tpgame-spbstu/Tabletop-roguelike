extends Spatial


onready var _pole: MeshInstance = $pole
onready var _flag: MeshInstance = $flag
onready var _tween: Tween = Tween.new()
const top = "top"
const bottom = "bottom"
const height = "height"
# ratio of the height of flag to the height of the flag pole
export(float, 0.01, 1, 0.2) var hfl_to_hpole = 0.2
# percentage of flag pole height to skip before the top of the flag
export(float, 0.01, 0.49, 0.05) var margin_from_top = 0.05
# percentage of flag pole height to skip before the bottom of the flag
export(float, 0.01, 0.49, 0.05) var margin_from_bottom = 0.05
# the animation will be player this number of seconds
export(int, 0.1, 4, 2) var anim_dur = 2


func _ready():
	_flag.hide()
	add_child(_tween)
	_tween.connect("tween_all_completed", self, "_on_tween_completed")


func get_pole_size():
	var cyl_mesh = _pole.mesh as CylinderMesh
	return Vector3(
		cyl_mesh.get_top_radius(),
		cyl_mesh.get_height(),
		cyl_mesh.get_bottom_radius()
	)
	# return {
	# 	top: cyl_mesh.get_top_radius(),
	# 	bottom: cyl_mesh.get_bottom_radius(),
	# 	height: cyl_mesh.get_height()
	# }


# func get_centered_trans():
# 	var pole_size = _get_pole_size()
# 	return Vector3(pole_size[top] / 2, pole_size[height] / 2, pole_size[top] / 2)


func get_flag_size():
	var plane_mesh = _flag.mesh as PlaneMesh
	return plane_mesh.get_size()


## shows the flag and plays its animation (movement from the bottom of the pole to its top)
func set_sail():
	var pole_size = get_pole_size()
	var fl_size = get_flag_size()
	# set the scale so that the `hfl_to_hstk` ratio is true
	var scale_coeff = pole_size.y / fl_size.y * hfl_to_hpole
	_flag.set_scale(Vector3.ONE * scale_coeff)
	# update the size (it was scaled)
	fl_size *= scale_coeff

	# get the coeffs for the flag's translations
	var pole_trans = _pole.get_translation()
	var trans_x = pole_trans.x + pole_size.x / 2 + fl_size.x / 2
	var trans_z = pole_trans.z
	# set `y` to any number, it will be changed during tween animation
	_flag.set_translation(Vector3(trans_x, 0, trans_z))
	# from the bottom of the pole, to the top of it
	var init_y = pole_trans.y - pole_size.y * (1 - margin_from_bottom) / 2 + fl_size.y / 2
	var final_y = pole_trans.y + pole_size.y * (1 - margin_from_top) / 2 - fl_size.y / 2

	_flag.show()
	# just for chuckles :) for normal use any of the commented below is recommended
	_tween.interpolate_property(_flag, "translation:y", init_y, final_y, anim_dur, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	# _tween.interpolate_property(_flag, "translation:y", init_y, final_y, anim_dur, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	# _tween.interpolate_property(_flag, "translation:y", init_y, final_y, anim_dur, Tween.TRANS_CIRC, Tween.EASE_OUT)
	_tween.start()


func _on_tween_completed():
	remove_child(_tween)
	_tween.queue_free()
