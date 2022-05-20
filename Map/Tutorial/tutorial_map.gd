extends Spatial
signal end_tutorial


class tutor_unit:
	var image
	var text
	func _init(image, text):
		self.image = image
		self.text = text
		

var image_path = "res://Map/Sprites/"
var cur_id = 0
var tutorial : Array


func generate_tutorial():
	tutorial.append(tutor_unit.new(image_path+"t_1.png", 
		"Перемещайтесь по Карте мира нажатием левой кнопки мыши по точкам"))
	tutorial.append(tutor_unit.new(image_path+"t_2.png", 
		"Меч над точкой означает, что на вашем пути противник, которого необходимо преодолеть!" +
		" Нажмите ЛКМ, чтобы вступить в сражение"))
	tutorial.append(tutor_unit.new(image_path+"t_3.png", 
		"Книга над точкой означает, что на данной локации можно улучшить ваши карты,"+
		" пополнить колоду и многое другое!"))
	pass
	
	
func run():
	generate_tutorial()
	next()
	

func next():
	if cur_id >= len(tutorial):
		return
	$Viewport/Node2D/Sprite.texture = load(tutorial[cur_id].image)
	$Viewport/Node2D/Label.text = tutorial[cur_id].text
	cur_id += 1


func _on_Button_pressed():
	if cur_id >= len(tutorial):
		emit_signal("end_tutorial")
	next()
	
