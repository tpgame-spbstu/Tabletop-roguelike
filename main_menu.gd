extends Control



func _on_exit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	var GameLoadManager = preload("res://game_load_manager.gd")
	var gameConfig = GameLoadManager.generate_new_game()
	var mapScene = preload("res://map.tscn").instance()
	self.get_parent().add_child(mapScene)
	mapScene.initialize(gameConfig)
	self.hide()
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()

func _on_continue_pressed():
	var GameLoadManager = preload("res://game_load_manager.gd")
	var gameConfig = GameLoadManager.load_game()
	var mapScene = preload("res://map.tscn").instance()
	self.get_parent().add_child(mapScene)
	mapScene.initialize(gameConfig)
	self.hide()
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()
