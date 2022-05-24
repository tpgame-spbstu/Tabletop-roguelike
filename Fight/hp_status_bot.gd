extends Spatial




func _on_fight_state_player_2_health_changed(player_2_health):
	$Viewport/Control/Label.text = player_2_health as String
