extends Label


export(DynamicFont) var font = DynamicFont.new()
export(DynamicFontData) var font_data = load("res://fonts/Ubuntu-B.ttf")
export(int, 4, 100, 56) var font_size = 56
export(int, 0, 10, 1) var outline_size = 1
export(Color, RGBA) var outline_color = Color(0, 0, 0, 1)
export(bool) var use_mipmaps = true
export(bool) var use_filter = true


func _ready():
	_configure()


func set_msg(msg):
	set_text(str(msg))
	# wait to update the size
	yield(get_tree(), "idle_frame")


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
