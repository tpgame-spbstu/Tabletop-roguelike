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
const DUR_CARD_DRAW: float = 0.2
# new scale value when the card is hovered
const SCALE_CARD_DRAW: float = 1.1
# duration of the scale and translate tweens when the
# card is unhovered (=undrawn)
const DUR_CARD_UNDRAW: float = 0.35
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


func on_enter(offset: Vector3):
    var card = get_parent()
    match get_state():
        EXIT:
            # stop the current exiting animatnion as we will start the entering one
            _reset()
            continue # fallthrough
        # aparently, in order to fallthrough one needs to have the original match in the branch
        NONE, EXIT:
            set_state(ENTER)
            card.set_scale(Vector3.ONE * 1.1)
            card.set_translation(card.get_orig_pos() + offset)
            # interpolate_property(card, "scale", card.scale, Vector3.ONE * SCALE_CARD_DRAW,
            #     DUR_CARD_DRAW, Tween.TRANS_CIRC, Tween.EASE_OUT)
            # interpolate_property(card, "translation", card.get_translation(), card.get_orig_pos() + offset,
            #     DUR_CARD_DRAW, Tween.TRANS_CIRC, Tween.EASE_OUT)
            start()


func on_exit():
    var card = get_parent()
    match get_state():
        ENTER:
            # stop the current entering animatnion as we will start the exiting one
            _reset()
            continue # fallthrough
        # aparently, in order to fallthrough one needs to have the original match in the branch
        NONE, ENTER:
            set_state(EXIT)
            card.set_scale(Vector3.ONE)
            card.set_translation(card.get_orig_pos())
            # interpolate_property(card, "scale", card.scale, Vector3.ONE,
            #     DUR_CARD_UNDRAW * (1 - SCALE_UNDRAW_OFF), Tween.TRANS_SINE, Tween.EASE_IN_OUT, DUR_CARD_UNDRAW * SCALE_UNDRAW_OFF)
            # interpolate_property(card, "translation", card.get_translation(), card.get_orig_pos(),
            #     DUR_CARD_UNDRAW, Tween.TRANS_CUBIC, Tween.EASE_IN)
            start()
