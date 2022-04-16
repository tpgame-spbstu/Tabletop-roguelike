extends Node

# GameSettings class - class for storing game settings values

# Audio

signal change_music_settings
signal change_effects_settings

var music_value = -15
var effects_value = -15
const max_value = 5
const min_value = -65
const general_volume = max_value - min_value

func set_music_volume(value):
	music_value = value/100*general_volume + min_value
	emit_signal("change_music_settings")
	
func set_effects_volume(value):
	effects_value = value/100*general_volume + min_value
	emit_signal("change_effects_settings")
