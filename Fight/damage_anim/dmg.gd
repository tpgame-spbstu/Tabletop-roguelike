extends Label


signal set_text


export(DynamicFont) var font = DynamicFont.new()
export(DynamicFontData) var font_data = load("res://fonts/Ubuntu-B.ttf")
export(int, 4, 100, 1) var font_size = 56
export(int, 0, 10, 1) var outline_size = 1
export(Color, RGBA) var outline_color = Color(0, 0, 0, 1)
export(bool) var use_mipmaps = true
export(bool) var use_filter = true

export(int, 1, 4) var max_chars = 4


func _ready():
	_configure()


func set_msg(msg):
	msg = str(msg)
	assert(msg.length() <= max_chars)
	set_text(msg)
	# wait to update the size
	yield(get_tree(), "idle_frame")
	# FIXME does nothing
	set_size(Vector2.ONE * max(get_size().x, get_size().y))
	# the size might've been changed with the new text
	# tell everyone 'bout it
	emit_signal("set_text")


# doesn't work, like at all
# let it be as a monument
#
# TODO: either find solution to draw the
# the label normally, or remove, since it does nothing
func get_recommened_vp_size() -> Vector2:
	return Vector2.ONE * max(get_size().x, max_chars * font_size) * 8


func _configure():
	set_align(ALIGN_CENTER)
	set_valign(VALIGN_CENTER)

	font.font_data = font_data
	font.set_size(font_size)
	font.set_outline_size(outline_size)
	font.set_outline_color(outline_color)
	font.use_mipmaps = use_mipmaps
	font.use_filter = use_filter
	set("custom_fonts/font", font)

	set_visible_characters(max_chars)
