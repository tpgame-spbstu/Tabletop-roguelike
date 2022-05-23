extends Spatial



func _on_fight_state_player_1_health_changed(player_1_health):
	$Viewport/Control/Label.text = player_1_health as String
