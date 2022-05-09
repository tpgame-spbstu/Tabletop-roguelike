extends Spatial

onready var label := $Viewport/label_wrapper/Label

func _ready():
	pass # Replace with function body.

func set_value(value):
	label.text = String(value)
