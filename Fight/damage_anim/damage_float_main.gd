extends Sprite3D

onready var _viewport: Viewport = $Viewport
onready var _dmg: Label = $Viewport/dmg

func _ready():
	_viewport.set_size(Vector2(100, 100))
	print("before ", _dmg.get_size())
	_dmg.set_msg("Yo!")
	print("after: ", _dmg.get_size())

	set_texture(_viewport.get_texture())
