extends Viewport


onready var _dmg: Label = $dmg

export(bool) var v_flip = true
export(bool) var is_transparent = true
enum _MSAA {  # couldn't set default MSAA enum, ended up with that
	MSAA_DISABLED,
	MSAA_2X,
	MSAA_4X,
	MSAA_8X,
	MSAA_16X,
}
export(_MSAA) var custom_msaa = _MSAA.MSAA_4X


func _ready():
	_configure()
	# in order to position the label correctly
	# one needs to be in sync with the size of the label,
	# which depends on the text displayed
	_dmg.connect("set_text", self, "_on_set_text")


func _on_set_text():
	# put the label in the center
	_dmg.set_position((get_size() - _dmg.get_size()) / 2)


func _configure():
	# by default the viewported img is flipped vertically
	# unflip it!
	set_vflip(v_flip)
	set_transparent_background(is_transparent)
	set_usage(USAGE_2D)
	set_update_mode(UPDATE_ALWAYS)
	set_msaa(custom_msaa)

	# FIXME does nothing
	set_size(_dmg.get_recommened_vp_size())
