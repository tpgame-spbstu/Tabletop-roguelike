extends Control


signal next_button_pressed()


func show_text(text, show_button= false):
	$tutorial_text/tutorial_label.bbcode_text = text
	show()
	if show_button:
		$tutorial_text/Button.show()
	else:
		$tutorial_text/Button.hide()


func _on_Button_pressed():
	emit_signal("next_button_pressed")
