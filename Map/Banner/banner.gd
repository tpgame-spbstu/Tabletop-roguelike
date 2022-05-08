extends Spatial


onready var _pole: MeshInstance = $pole
onready var _flag: MeshInstance = $flag
# @warn: if changing the texture, set the correct
#        translation! (it's shifted for the current one)
onready var _inc_cirle: Sprite3D = $incantation_circle
onready var _tween: Tween = Tween.new()
# ratio of the height of flag to the height of the flag pole
export(float, 0.01, 1, 0.01) var hfl_to_hpole = 0.2
# percentage of flag pole height to skip before the top of the flag
export(float, 0.01, 0.49, 0.01) var margin_from_top = 0.05
# percentage of flag pole height to skip before the bottom of the flag
export(float, 0.01, 0.49, 0.01) var margin_from_bottom = 0.05
# the flag raising will be played this number of seconds
export(float, 0.1, 4, 0.1) var flag_raising_dur = 2
# the incantation circle will fully appear in this num of secs
export(float, 0.1, 4, 0.1) var inc_appearance_dur = 2
# the desired scaling will be reached in this num of secs
export(float, 0.1, 4, 0.1) var inc_scaling_dur = 2
# the desired scaling of the incantation cirle
export(float, 0.1, 1, 0.1) var inc_scale_coeff = 0.5
# the pole will take its place in this num of secs
export(float, 0.1, 4, 0.1) var pole_appearance_dur = 2
# the incantation cirle will fully disappear in this num of secs
export(float, 0.1, 4, 0.1) var inc_disappearance_dur = 2
# the incantation cirle will be descaled in this num of secs
export(float, 0.1, 4, 0.1) var inc_descaling_dur = 2
# whether to descale the incantation circle (it will be made invisible anyway)
export(bool) var descaling = true


func _ready():
	# hide all of them
	# their appearance is controlled by tweens
	_pole.hide()
	_flag.hide()
	_inc_cirle.hide()


func get_pole_size():
	var cyl_mesh = _pole.mesh as CylinderMesh
	return Vector3(
		cyl_mesh.get_top_radius(),
		cyl_mesh.get_height(),
		cyl_mesh.get_bottom_radius()
	)


func get_flag_size():
	var plane_mesh = _flag.mesh as PlaneMesh
	return plane_mesh.get_size()


## let the pole make its appearance on the scene
func _show_stick():
	# need to mentally prepare both the `_inc_cirle` and the `_pole`
	# before appearing on the scene. If not, they will appear as is
	# firtly, then the tween will start: set the fully shown `_inc_cirle_`
	# to being invisible with "modulate:a" -> disappear shortly after appearing, BAD
	_inc_cirle.modulate.a = 0
	_inc_cirle.show()
	var pole_offset = get_pole_size().y / 2
	_pole.translation.y -= pole_offset
	_pole.show()

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(_inc_cirle, "modulate:a", 0, 1,
		inc_appearance_dur, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_property(_inc_cirle, "scale", Vector3.ZERO, Vector3.ONE * inc_scale_coeff,
		inc_scaling_dur, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(_pole, "translation:y", -pole_offset, pole_offset,
		pole_appearance_dur, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	# wait for the tween to end for the flag not to appear before the pole is at its final position
	yield(tween, "tween_all_completed")

	# immediately after start the disappearing of the incantation circle. will be animated at the 
	# same time the flag is raising
	tween.interpolate_property(_inc_cirle, "modulate:a", 1, 0,
		inc_disappearance_dur, Tween.TRANS_SINE, Tween.EASE_IN)
	if descaling:
		tween.interpolate_property(_inc_cirle, "scale", _inc_cirle.get_scale(), Vector3.ZERO,
			inc_descaling_dur, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	# thank you for your service, sir!
	tween.connect("tween_all_completed", self, "_on_tween_completed", [tween])


## shows the flag and plays its animation (movement from the bottom of the pole to its top)
##
## :animate: whether to animate the flag and stuff or just to make it shown
func set_sail(animate: bool):
	var pole_size = get_pole_size()
	var fl_size = get_flag_size()
	# set the scale so that the `hfl_to_hstk` ratio is true
	var scale_coeff = pole_size.y / fl_size.y * hfl_to_hpole
	_flag.set_scale(Vector3.ONE * scale_coeff)
	# update the size (it was scaled)
	fl_size *= scale_coeff

	if not animate:
		_pole.translation.y = pole_size.y / 2
		_pole.show()

		var fl_trans = _pole.get_translation()
		fl_trans.x += pole_size.x / 2 + fl_size.x / 2
		fl_trans.y += pole_size.y * (1 - margin_from_top) / 2 - fl_size.y / 2
		_flag.set_translation(fl_trans)
		_flag.show()
	else:
		# no flag without a stick, huh?
		yield(_show_stick(), "completed")

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
		var tween = Tween.new()	
		add_child(tween)
		# just for chuckles :) for normal use any of the commented below is recommended
		tween.interpolate_property(_flag, "translation:y", init_y, final_y, flag_raising_dur, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		# _tween.interpolate_property(_flag, "translation:y", init_y, final_y, anim_dur, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		# _tween.interpolate_property(_flag, "translation:y", init_y, final_y, anim_dur, Tween.TRANS_CIRC, Tween.EASE_OUT)
		tween.start()
		tween.connect("tween_all_completed", self, "_on_tween_completed", [tween])


func _on_tween_completed(tween):
	remove_child(tween)
	tween.queue_free()
