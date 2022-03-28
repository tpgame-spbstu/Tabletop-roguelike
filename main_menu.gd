extends Control



func _on_exit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	var gameConfig = GameLoadManager.generate_new_game()
	var mapScene = preload("res://map.tscn").instance()
	mapScene.initialization(gameConfig)
	self.get_parent().add_child(mapScene)
	self.hide()
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()

func _on_continue_pressed():
	var gameConfig = GameLoadManager.load_game()
	var mapScene = preload("res://map.tscn").instance()
	mapScene.initialization(gameConfig)
	self.get_parent().add_child(mapScene)
	self.hide()
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()
