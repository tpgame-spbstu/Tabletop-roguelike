extends Sprite3D

onready var _viewport = $Viewport
onready var _dmg = $Viewport/dmg


func _ready():
	_dmg.set_msg("3")

	set_texture(_viewport.get_texture())
	set_billboard_mode(SpatialMaterial.BILLBOARD_ENABLED)
