extends Control

onready var label := $Label

func _ready():
	pass # Replace with function body.

func set_text(text):
	label.text = text


func get_label():
	return label
