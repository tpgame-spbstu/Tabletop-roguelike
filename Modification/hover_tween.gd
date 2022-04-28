extends Tween

class_name HoverTween

enum {
	NONE, # no animation
	ENTER, # animation on mouse entering the card's collision obj
	EXIT, # animation on mouse exiting the card's collision obj
}
var _state setget set_state, get_state
# duration of scale and translate tweens when the
# card is hovered (=drawn from the hand)
const DUR_CARD_DRAW: float = 0.4
# new scale value when the card is hovered
const SCALE_CARD_DRAW: float = 1.2
# duration of the scale and translate tweens when the
# card is unhovered (=undrawn)
const DUR_CARD_UNDRAW: float = 0.4
# offset for scale tween on undrawing the card
# without it the both the tweens start at the same
# time, which produces unpleasant result
const SCALE_UNDRAW_OFF: float = 0.9


func set_state(state):
	assert(state >= NONE and state <= EXIT)
	_state = state


func get_state():
	return _state


func _reset():
	remove_all()
	set_state(NONE)


func is_active():
	return get_state() != NONE


func on_enter(offset: Vector3):
	var card = get_parent()
	match get_state():
		EXIT:
			# stop the current exiting animation as we will start the entering one
			_reset()
			continue # fall-through
		# apparently, in order to fall-through one needs to have the original match in the branch
		NONE, EXIT:
			set_state(ENTER)
			card.set_scale(Vector3.ONE * SCALE_CARD_DRAW)
			card.rotate(Vector3.UP, -card.get_rotation().y)

			var port = get_viewport()
			var end = port.get_visible_rect().end
			var d3_end = port.get_camera().project_position(end, 0)
			var card_pos = card.get_orig_trans().origin
			var anim_end = Vector3(card_pos.x, 0.5, d3_end.z - (card.get_size()*card.get_scale()).z / 2)

			interpolate_property(card, "translation", card.get_orig_trans().origin, card.get_orig_trans().origin + offset,
			# interpolate_property(card, "translation", card.get_orig_trans().origin, anim_end,
				DUR_CARD_DRAW, Tween.TRANS_CIRC, Tween.EASE_OUT)
			start()


func on_exit():
	var card = get_parent()
	match get_state():
		ENTER:
			# stop the current entering animation as we will start the exiting one
			_reset()
			continue # fall-through
		# apparently, in order to fall-through one needs to have the original match in the branch
		NONE, ENTER:
			set_state(EXIT)
			card.set_scale(Vector3.ONE)
			var vec = Vector3.FORWARD.rotated(Vector3.UP, card.get_orig_rot_y())
			card.rotate(Vector3.UP, card.get_orig_rot_y())
			# draw the card in the deck
			interpolate_property(card, "translation", card.get_orig_trans().origin + vec, card.get_orig_trans().origin,
				DUR_CARD_UNDRAW, Tween.TRANS_CUBIC, Tween.EASE_IN)
			start()
