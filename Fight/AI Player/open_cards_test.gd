extends Spatial


func _on_open_cards_card_changed(val):
	$ProgressBar.ratio = val
