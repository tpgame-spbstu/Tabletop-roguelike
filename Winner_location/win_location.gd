extends "res://Map/Location/location.gd"

onready var dialog_cloud_text = $Viewport/dialog/Label
onready var ant = $ant
onready var anim_text = $Viewport/dialog/AnimationPlayer

var speech = [
	"Папич говорил:",
	"Как сделать максимально опасного воина?", 
	"Берем простого крестьянина, который вообще ничего не умеет",
	"Обучаем его работать с копьем две недели",
	"Все! Отправляем на войну",
	"Ты победил!"
	]
var cur_id_speech = 0
var return_map_text = "Retrun to map"


func initialize(deck_config, inventory_config, params : Dictionary):
	.initialize(deck_config, inventory_config, params)
	$Camera.make_current()
	ant.connect("input_ant", self, "_on_input_ant")
	anim_text.play("text_animation")
	dialog_cloud_text.text = speech[cur_id_speech]
	

func next_speech():
	if cur_id_speech < len(speech) - 1:
		cur_id_speech+=1
		dialog_cloud_text.text = speech[cur_id_speech]
		anim_text.play("text_animation")


func _on_input_ant():
	self.next_speech()
	pass


func _on_Button_pressed():
	self.next_speech()
	if $Button.text == return_map_text:
		emit_signal("return_to_map", "lose")
	elif cur_id_speech == len(speech) - 1:
		$Button.text = return_map_text
	
