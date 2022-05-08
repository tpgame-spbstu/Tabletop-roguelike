extends Sprite3D

signal tween_finished

onready var _viewport = $Viewport
onready var _dmg = $Viewport/dmg
onready var _tween = Tween.new()

export(float, 0.1, 4, 0.1) var life_time = 2  # time of animation
export(float, 0, 4, 0.01) var wait_for = 0.4  # time to wait for before the animation
export(Vector3) var direction = Vector3.UP  # direction of movement
export(float, 0.01, 1.6, 0.01) var spread_angle = PI / 2  # angle range relative to origin one
export(float, 0.1, 2.0, 0.1) var crit_dur = 0.4  # time of crit animation
export(float, 1.1, 3, 0.1) var crit_scale = 2  # coeff for scaling
export(Color, RGBA) var crit_color = Color(1, 0, 0, 1)


func _ready():
	set_texture(_viewport.get_texture())
	set_billboard_mode(SpatialMaterial.BILLBOARD_ENABLED)

	add_child(_tween)


func _on_tween_finished():
	emit_signal("tween_finished")


## create the damage sticker
##
## :dmg: number, max 4 symbols (FIXME msg length does nothing to the viewport's size now)
## :dest: destination vector relative to `global_transform`
## :wait: offset before the start of animation
## :crit: whether to display the msg as a crit one
## :dur: duration of dissappearing animation
## :spread: spreading angle. The `dest` vector is rotated in between `spread/2` over FORWARD vec
##
## :return: void, calls `_on_tween_finished` on tween completion
func create(dmg, dest=direction, wait=wait_for, crit=false, dur=life_time, spread=spread_angle) -> void:
	_dmg.set_msg(int(dmg))

	var movement = dest.rotated(Vector3.FORWARD, rand_range(-spread / 2, spread / 2))

	_tween.interpolate_property(self, "global_transform:origin", get_global_transform().origin, get_global_transform().origin + movement,
		dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait)
	_tween.interpolate_property(_dmg, "modulate:a", 1.0, 0.0,
		dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, wait)

	if crit:
		modulate = crit_color
		_tween.interpolate_property(self, "scale", get_scale() * crit_scale, get_scale(), crit_dur, Tween.TRANS_BACK, Tween.EASE_IN, wait)

	_tween.start()
	_tween.connect("tween_all_completed", self, "_on_tween_finished", [], CONNECT_ONESHOT)
