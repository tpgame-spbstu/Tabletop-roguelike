extends Sprite3D

onready var _viewport = $Viewport
onready var _dmg = $Viewport/dmg

export(int, 0.1, 4, 0.1) var life_time = 2
export(Vector3) var direction = Vector3.UP
export(float, 0.01, 1.6, 0.01) var spread_angle = PI / 2
export(float, 0.1, 2.0, 0.1) var crit_dur = 0.4
export(float, 1.1, 3, 0.1) var crit_scale = 2
export(Color, RGBA) var crit_color = Color(1, 0, 0, 1)


func _ready():
	set_texture(_viewport.get_texture())
	set_billboard_mode(SpatialMaterial.BILLBOARD_ENABLED)


## create the damage sticker
##
## :dmg: number, max 4 symbols (FIXME msg length does nothing to the viewport's size now)
## :crit: whether to display the msg as a crit one
## :dur: duration of dissappearing animation
## :dest: destination vector relative to `global_transform`
## :spread: spreading angle. The `dest` vector is rotated in between `spread/2` over FORWARD vec
##
## :return: void
func create(dmg, crit=false, dur=life_time, dest=direction, spread=spread_angle) -> void:
	_dmg.set_msg(int(dmg))

	var tween = Tween.new()
	add_child(tween)
	var movement = dest.rotated(Vector3.FORWARD, rand_range(-spread / 2, spread / 2))

	tween.interpolate_property(self, "global_transform:origin", get_global_transform().origin, get_global_transform().origin + movement,
		dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(_dmg, "modulate:a", 1.0, 0.0,
		dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	if crit:
		modulate = crit_color
		tween.interpolate_property(self, "scale", get_scale() * crit_scale, get_scale(), crit_dur, Tween.TRANS_BACK, Tween.EASE_IN)

	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
