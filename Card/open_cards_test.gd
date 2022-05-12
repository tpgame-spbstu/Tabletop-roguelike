extends Spatial


func _on_open_cards_card_changed(val):
	$ProgressBar.ratio = val


func _ready():
	var card
	card = $card1
	remove_child(card)
	$open_cards.add_card(card)
	card = $card2
	remove_child(card)
	$open_cards.add_card(card)
	card = $card3
	remove_child(card)
	$open_cards.add_card(card)
	card = $card4
	remove_child(card)
	$open_cards.add_card(card)


func _on_open_cards_card_left_click(card):
	if card:
		$open_cards.remove_card(card)


func _on_open_cards_card_right_click(card):
	$open_cards.remove_empty()
