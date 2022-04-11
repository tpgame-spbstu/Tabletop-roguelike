extends Control


func _ready():
	$main.show()
	$OptionMenu.hide()
	$OptionMenu/MusicScroll.value = 70
	$OptionMenu/EffectsScroll.value = 70
	$AudioStreamPlayer.playing = true
	GameSettings.connect("change_music_settings",self, "_on_change_music_value")
	GameSettings.set_music_volume($OptionMenu/MusicScroll.value)
	GameSettings.set_effects_volume($OptionMenu/EffectsScroll.value)
	


func _on_exit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	var GameLoadManager = preload("res://game_load_manager.gd")
	var gameConfig = GameLoadManager.generate_new_game()
	var mapScene = preload("res://Map/map.tscn").instance()
	self.get_parent().add_child(mapScene)
	$AudioStreamPlayer.playing = false
	self.hide()
	mapScene.initialize(gameConfig)
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()
	$AudioStreamPlayer.playing = true

func _on_continue_pressed():
	var GameLoadManager = preload("res://game_load_manager.gd")
	var gameConfig = GameLoadManager.load_game()
	var mapScene = preload("res://Map/map.tscn").instance()
	self.get_parent().add_child(mapScene)
	$AudioStreamPlayer.playing = false
	self.hide()
	mapScene.initialize(gameConfig)
	yield(mapScene,"return_to_main_menu")
	print("ok")
	mapScene.queue_free()
	self.show()
	$AudioStreamPlayer.playing = true
	
func _on_option_pressed():
	$main.hide()
	$OptionMenu.show()
	
func _on_back_pressed():
	$main.show()
	$OptionMenu.hide()
	
func _on_fullscreen_pressed():
	OS.set_window_fullscreen(true)
	
func _on_windscreen_pressed():
	OS.set_window_fullscreen(false)
	
func _on_music_scrolling():
	GameSettings.set_music_volume($OptionMenu/MusicScroll.value)
	
func _on_effects_scrolling():
	GameSettings.set_effects_volume($OptionMenu/EffectsScroll.value)
	
func _on_change_music_value():
	$AudioStreamPlayer.volume_db = GameSettings.music_value

